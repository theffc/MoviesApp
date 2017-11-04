//
//  VideosSearchViewController.swift
//  Movies
//
//  Created by Frederico Franco on 02/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import UIKit
import Moya
import SDWebImage

class VideosSearchViewController: UIViewController {

//    enum Model {
//        case loading
//        case loaded(results: [MovieSearch])
//        case error
//    }
//    var model: Model! {
//        didSet {
//            switch model! {
//            case .loading:
//                movies = []
//                tableView.reloadData()
//                activityIndicator.startAnimating()
//            case let .loaded(results: results):
//                movies = results
//                tableView.reloadData()
//                activityIndicator.stopAnimating()
//            case .error:
//                activityIndicator.stopAnimating()
//            }
//        }
//    }
    
    var movies: [MovieSearch] = []
    
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    @IBOutlet fileprivate weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    fileprivate var searchController: UISearchController!
    fileprivate func setupSearch() {
        let s = UISearchController(searchResultsController: nil)
        
        // TODO: criar uma classe separada para ser o searchUpdater e setar aqui
        s.searchResultsUpdater = self
        
        s.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        
        self.tableView.tableHeaderView = s.searchBar
        
        s.searchBar.placeholder = "Pesquisar por filmes"
        s.searchBar.autocorrectionType = .no
        s.searchBar.autocapitalizationType = .none
        s.searchBar.spellCheckingType = .no
        
        searchController = s
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        makeSearchBarActive()
    }
    
    fileprivate func makeSearchBarActive() {
        searchController.isActive = true
        // async because we need to call only when the searchController presentation ends (which was triggered by setting isActive to true), and, without async, we could't achieve that.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    fileprivate var lastScheduledQuery: String = ""
}

extension VideosSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        guard query != lastScheduledQuery else {
            return
        }
        
        activityIndicator.stopAnimating()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchForMovies(_:)), object: lastScheduledQuery)
        
        guard !query.isEmpty else {
            return
        }
        
        scheduleNewSearch(query: query)
    }
    
    fileprivate func scheduleNewSearch(query: String) {
        perform(#selector(searchForMovies(_:)), with: query, afterDelay: 0.8)
        lastScheduledQuery = query
    }
    
    @objc func searchForMovies(_ query: String) {
        movies = []
        tableView.reloadData()
        
        activityIndicator.startAnimating()
        
        let provider = MoyaProvider<OmdbApi>()
        provider.request(.searchMovie(title: query, page: 1)) {
            [weak self] result in
            
            guard let this = self else {
                return
            }
            
            guard this.isCurrentQuery(query) else {
                return
            }
            
            this.activityIndicator.stopAnimating()
            
            switch result {
            case let .failure(error):
                print(error)
                return
            case let .success(value):
                do {
                    let search = try value.map(SearchResult.self)
                    this.movies = search.movies
                }
                catch {
                    print(error)
                    return
                }
            }
            
            this.tableView.reloadData()
        }
    }
    
    fileprivate func isCurrentQuery(_ query: String) -> Bool {
        return query == searchController.searchBar.text
    }
}

extension VideosSearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.videosSearchCell, for: indexPath) else {
            fatalError("Problem dequeueing VideosSearchCell!")
        }
        
        let movie = movies[indexPath.row]
        cell.updateView(for: movie)
        
        return cell
    }
}

extension VideosSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let provider = MoyaProvider<OmdbApi>()
        print(movie.imdbId)
        provider.request(.movie(id: movie.imdbId)) { (result) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(value):
                let str = String(data: value.data, encoding: .utf8)!
                //print(str)
                
                do {
                    let r = try value.map(Movie.self)
                    //print(r)
                } catch {
                    print(error)
                }
            }
        }
    }
}


class VideosSearchCell: UITableViewCell {
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var mediaLabel: UILabel!
    
    func updateView(for movie: MovieSearch) {
        posterView.sd_setImage(with: URL(string: movie.poster), completed: nil)
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        mediaLabel.text = movie.type.rawValue.capitalized
    }
}

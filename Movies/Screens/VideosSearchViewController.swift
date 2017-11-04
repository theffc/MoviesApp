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

class VideosSearchViewController: UIViewController, VideoSearchManagerDelegate {

    var provider: MovieSearchProviderType = MovieSearchRemoteProvider()
    
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
    fileprivate var searchManager: VideoSearchManager!
    fileprivate func setupSearch() {
        let s = UISearchController(searchResultsController: nil)
        
        searchManager = VideoSearchManager(delegate: self, searchController: s, tableViewToAddInfiniteScroll: tableView)
        s.searchResultsUpdater = searchManager
        
        s.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        tableView.tableHeaderView = s.searchBar
        
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
    
    func videoSearchManager(_ manager: VideoSearchManager, didChangeState state: Loadable<VideoSearchResult, Error>) {
        switch state {
        case .loading:
            movies = []
            tableView.reloadData()
            activityIndicator.startAnimating()
        
        case let .loaded(result):
            activityIndicator.stopAnimating()
            
            if result.shouldAppendNewResultsWithPrevious {
                movies.append(contentsOf: result.movies)
                tableView.finishInfiniteScroll()
            } else {
                movies = result.movies
            }
            
            tableView.reloadData()
            
        case .error(_):
            activityIndicator.stopAnimating()
            tableView.finishInfiniteScroll()
        }
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

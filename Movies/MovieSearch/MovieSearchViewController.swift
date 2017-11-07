//
//  MovieSearchViewController.swift
//  Movies
//
//  Created by Frederico Franco on 02/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import UIKit
import Moya
import SDWebImage

class MovieSearchViewController: UIViewController, MovieSearchManagerDelegate {

    var provider: MovieSearchProviderType = MovieSearchRemoteProvider()
    
    var movies: [MovieSearchModel] = []
    
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
    fileprivate var searchManager: MovieSearchManager!
    fileprivate func setupSearch() {
        let s = UISearchController(searchResultsController: nil)
        
        searchManager = MovieSearchManager(searchController: s, delegate: self)
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
        setupInfiniteScroll(in: tableView)
        
        navigationItem.title = "Pesquisar"
    }
    
    fileprivate func setupInfiniteScroll(in tableView: UITableView) {
        tableView.setShouldShowInfiniteScrollHandler() {
            [weak self] _ in
            guard let weak = self else {
                return false
            }
            
            return weak.searchManager.currentSearch.hasMoreContent
        }
        
        tableView.addInfiniteScroll(handler: {
            [weak self] (table) in
            guard let weak = self else {
                return
            }
            
            weak.searchManager.triggerSearchForNextPage()
        })
        
        tableView.infiniteScrollIndicatorMargin = 20
    }    
    
    func movieSearchManager(_ manager: MovieSearchManager, didChangeSearchState search: MovieSearchManager.Search) {
        switch search.resultState {
        case .loading:
            guard search.page == manager.initialPage else {
                return
            }
            
            movies = []
            tableView.reloadData()
            activityIndicator.startAnimating()
        
        case let .loaded(movies):
            activityIndicator.stopAnimating()
            
            if search.page == manager.initialPage {
                self.movies = movies
            } else {
                self.movies.append(contentsOf: movies)
                tableView.finishInfiniteScroll()
            }
            
            tableView.reloadData()
            
        case .error(_):
            activityIndicator.stopAnimating()
            tableView.finishInfiniteScroll()
        }
    }
}

extension MovieSearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.movieSearchCell, for: indexPath) else {
            fatalError("Problem dequeueing VideosSearchCell!")
        }
        
        let movie = movies[indexPath.row]
        cell.updateView(for: movie)
        
        return cell
    }
}

extension MovieSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let vc = MovieDetailViewController.staticInit(input: .movieSearch(movie))
        show(vc, sender: self)
    }
}


class MovieSearchCell: UITableViewCell {
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var mediaLabel: UILabel!
    
    func updateView(for movie: MovieSearchModel) {
        posterView.sd_setImage(with: URL(string: movie.poster), completed: nil)
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        mediaLabel.text = movie.type.rawValue.capitalized
    }
}

//
//  MovieSearchManager.swift
//  Movies
//
//  Created by Frederico Franco on 04/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import Foundation
import Result


protocol MovieSearchManagerDelegate: class {
    
    func movieSearchManager(_ manager: MovieSearchManager, didChangeSearchState search: MovieSearchManager.Search)
}

class MovieSearchManager: NSObject, UISearchResultsUpdating {
    
    var provider: MovieSearchProviderType
    
    weak var delegate: MovieSearchManagerDelegate?
    
    fileprivate let searchController: UISearchController!
    
    init(searchController: UISearchController, delegate: MovieSearchManagerDelegate, provider: MovieSearchProviderType = MovieSearchRemoteProvider()) {
        self.delegate = delegate
        self.searchController = searchController
        self.provider = provider
        self.currentSearch = Search.empty(initialPage: provider.initialPage)
        
        super.init()
        
        searchController.searchResultsUpdater = self
    }
    
    class Search {
        let query: String
        var page: Int
        var resultState: Loadable<[MovieSearchModel], AnyError>
        var hasMoreContent: Bool
        
        init(query: String, page: Int, resultState: Loadable<[MovieSearchModel], AnyError> = .loading, hasMoreContent: Bool = false) {
            self.query = query
            self.page = page
            self.resultState = resultState
            self.hasMoreContent = hasMoreContent
        }
        
        static func empty(initialPage: Int) -> Search {
            return Search(query: "", page: initialPage, resultState: .loaded([]), hasMoreContent: false)
        }
    }
    
    fileprivate(set) var currentSearch: Search
    
    var initialPage: Int {
        return provider.initialPage
    }
    
    fileprivate var pageSize: Int {
        return provider.pageSize
    }
    
    fileprivate var lastScheduledQuery: String = ""
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        guard query != lastScheduledQuery else {
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(newSearch(_:)), object: lastScheduledQuery)
        
        if query.isEmpty {
            currentSearch = Search(query: "", page: initialPage, resultState: .loaded([]), hasMoreContent: false)
            delegate?.movieSearchManager(self, didChangeSearchState: currentSearch)
        } else {
            scheduleNewSearch(query: query)
        }
    }
    
    fileprivate func scheduleNewSearch(query: String) {
        perform(#selector(newSearch(_:)), with: query, afterDelay: 1)
        lastScheduledQuery = query
    }
    
    @objc func newSearch(_ query: String) {
        guard isCurrentQuery(query) else {
            return
        }
        
        currentSearch = Search(query: query, page: initialPage)
        searchForMovies()
    }
    
    func triggerSearchForNextPage() {
        switch currentSearch.resultState {
        case .loading:
            return
        
        case .error(_):
            searchForMovies()
            
        case .loaded(_):
            currentSearch.page = currentSearch.page + 1
            searchForMovies()
        }
    }
    
    @objc func searchForMovies() {
        currentSearch.resultState = .loading
        delegate?.movieSearchManager(self, didChangeSearchState: currentSearch)
        
        provider.searchForMovie(query: currentSearch.query, page: currentSearch.page) {
            [weak self] (result) in
            
            guard let weak = self else {
                return
            }
            
            guard weak.isCurrentQuery(weak.currentSearch.query) else {
                return
            }
            
            switch result {
            case let .failure(error):
                weak.currentSearch.resultState = .error(error)
                weak.currentSearch.hasMoreContent = weak.currentSearch.page != weak.initialPage
                weak.delegate?.movieSearchManager(weak, didChangeSearchState: weak.currentSearch)
                
            case let .success(success):
                weak.currentSearch.resultState = .loaded(success.movies)
                weak.currentSearch.hasMoreContent = success.hasMoreContent
                weak.delegate?.movieSearchManager(weak, didChangeSearchState: weak.currentSearch)
            }
        }
    }
    
    fileprivate func isCurrentQuery(_ query: String) -> Bool {
        return query == searchController.searchBar.text
    }
}

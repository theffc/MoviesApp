//
//  VideoSearchManager.swift
//  Movies
//
//  Created by Frederico Franco on 04/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import Foundation
import Result

struct VideoSearchResult {
    
    let movies: [MovieSearch]
    let shouldAppendNewResultsWithPrevious: Bool
}

protocol VideoSearchManagerDelegate: class {
    
    func videoSearchManager(_ manager: VideoSearchManager, didChangeState state: Loadable<VideoSearchResult, Error>)
}

class VideoSearchManager: NSObject, UISearchResultsUpdating {
    
    var provider: MovieSearchProviderType = MovieSearchRemoteProvider()
    
    weak var delegate: VideoSearchManagerDelegate?
    
    fileprivate let searchController: UISearchController!
    
    init(delegate: VideoSearchManagerDelegate, searchController: UISearchController, tableViewToAddInfiniteScroll tableView: UITableView) {
        self.delegate = delegate
        self.searchController = searchController
        
        super.init()
        
        searchController.searchResultsUpdater = self
        
        setupInfiniteScroll(in: tableView)
    }
    
    fileprivate func setupInfiniteScroll(in tableView: UITableView) {
        tableView.setShouldShowInfiniteScrollHandler() { _ in
            guard let search = self.lastCompletedSearch else {
                return false
            }
            
            return search.hasMoreContent
        }
        
        tableView.addInfiniteScroll(handler: { (table) in
            guard let search = self.lastCompletedSearch else {
                table.finishInfiniteScroll()
                return
            }
            
            self.pageToSearch = self.pageToSearch + 1
            self.searchForMovies(search.query)
        })
        
        tableView.infiniteScrollIndicatorMargin = 20
    }
    
    fileprivate var lastScheduledQuery: String = ""
    fileprivate var lastCompletedSearch: MovieSearchProviderResult?
    
    fileprivate var pageSize: Int {
        return provider.fixedPageSize ?? 10
    }
    
    fileprivate lazy var pageToSearch = provider.initialPage
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        guard query != lastScheduledQuery else {
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(newSearch(_:)), object: lastScheduledQuery)
        
        guard !query.isEmpty else {
            lastCompletedSearch = nil
            
            let result = VideoSearchResult(movies: [], shouldAppendNewResultsWithPrevious: false)
            delegate?.videoSearchManager(self, didChangeState: .loaded(result))
            return
        }
        
        scheduleNewSearch(query: query)
    }
    
    fileprivate func scheduleNewSearch(query: String) {
        perform(#selector(newSearch(_:)), with: query, afterDelay: 1)
        lastScheduledQuery = query
    }
    
    @objc func newSearch(_ query: String) {
        guard isCurrentQuery(query) else {
            return
        }
        
        delegate?.videoSearchManager(self, didChangeState: .loading)
        
        lastCompletedSearch = nil
        pageToSearch = provider.initialPage
        searchForMovies(query)
    }
    
    @objc func searchForMovies(_ query: String) {
        
        provider.searchForMovie(query: query, page: pageToSearch) {
            [weak self] (result) in
            
            guard let weak = self, let delegate = weak.delegate else {
                return
            }
            
            guard weak.isCurrentQuery(query) else {
                return
            }
            
            switch result {
            case let .failure(error):
                delegate.videoSearchManager(weak, didChangeState: .error(AnyError(error)))
                
            case let .success(success):
                weak.lastCompletedSearch = success
                let shouldAppend = success.page != weak.provider.initialPage
                let result = VideoSearchResult(movies: success.movies, shouldAppendNewResultsWithPrevious: shouldAppend)
                delegate.videoSearchManager(weak, didChangeState: .loaded(result))
            }
        }
    }
    
    fileprivate func isCurrentQuery(_ query: String) -> Bool {
        return query == searchController.searchBar.text
    }
}

//
//  MovieSearchProvider.swift
//  Movies
//
//  Created by Frederico Franco on 04/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import Moya
import Result

struct MovieSearchProviderResult {
    let query: String
    let page: Int
    let movies: [MovieSearch]
    let hasMoreContent: Bool
}

protocol MovieSearchProviderType {
    
    typealias Handler = (Result<MovieSearchProviderResult, AnyError>) -> Void
    
    func searchForMovie(query: String, page: Int, handler: @escaping Handler)
    
    var pageSize: Int { get }
    
    var fixedPageSize: Int? { get }
    
    var initialPage: Int { get }
}



class MovieSearchRemoteProvider: MovieSearchProviderType {
    
    let pageSize = 10
    
    let initialPage = 1
    
    var fixedPageSize: Int? = 10
    
    fileprivate let provider = MoyaProvider<OmdbApi>()
    
    func searchForMovie(query: String, page: Int, handler: @escaping (Result<MovieSearchProviderResult, AnyError>) -> Void) {
        provider.request(.searchMovie(title: query, page: page)) { result in
            switch result {
            case let .failure(error):
                handler(.failure(AnyError(error)))
                
            case let .success(value):
                do {
                    let search = try value.map(SearchResult.self)
                    let success = self.makeSuccessModel(query: query, result: search, page: page)
                    handler(.success(success))
                }
                catch {
                    handler(.failure(AnyError(error)))
                }
            }
        }
    }
    
    fileprivate func makeSuccessModel(query: String, result: SearchResult, page: Int) -> MovieSearchProviderResult {
        let has = self.hasMoreContent(currentPage: page, currentPageSize: result.movies.count, totalResults: Int(result.totalResults))
        return MovieSearchProviderResult(query: query, page: page, movies: result.movies, hasMoreContent: has)
    }
    
    fileprivate func hasMoreContent(currentPage: Int, currentPageSize: Int, totalResults: Int?) -> Bool {
        guard let totalResults = totalResults else {
            return true
        }
        
        return (((currentPage - 1) * pageSize) + currentPageSize) < totalResults
    }
}

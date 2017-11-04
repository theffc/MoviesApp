//
//  MovieSearchProvider.swift
//  Movies
//
//  Created by Frederico Franco on 04/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import Moya
import Result

protocol MovieSearchProviderType {
    
    typealias Handler = (Result<[MovieSearch], AnyError>) -> Void
    
    func searchForMovie(query: String, page: Int, handler: @escaping Handler)
    
    var fixedPageSize: Int? { get }
    
    var initialPage: Int { get }
}



class MovieSearchRemoteProvider: MovieSearchProviderType {
    
    let initialPage: Int = 1
    
    var fixedPageSize: Int? = 10
    
    fileprivate let provider = MoyaProvider<OmdbApi>()
    
    func searchForMovie(query: String, page: Int, handler: @escaping (Result<[MovieSearch], AnyError>) -> Void) {
        provider.request(.searchMovie(title: query, page: page)) { result in
            switch result {
            case let .failure(error):
                handler(.failure(AnyError(error)))
                
            case let .success(value):
                do {
                    let search = try value.map(SearchResult.self)
                    handler(.success(search.movies))
                }
                catch {
                    handler(.failure(AnyError(error)))
                }
            }
        }
    }
}

//
//  MovieModelProvider.swift
//  Movies
//
//  Created by Frederico Franco on 05/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import Foundation
import Moya
import Result


protocol MovieModelProviderType {
    
    typealias Handler = (Result<MovieModel, AnyError>) -> Void
    
    func requestMovie(id: String, handler: @escaping Handler)
}

class MovieModelRemoteProvider: MovieModelProviderType {
    
    private let provider = MoyaProvider<OmdbApi>()
    
    func requestMovie(id: String, handler: @escaping MovieModelProviderType.Handler) {
        provider.request(.movie(id: id)) { result in
            switch result {
            case let .failure(error):
                handler(.failure(AnyError(error)))
                
            case let .success(value):
                do {
                    let movie = try value.map(MovieModel.self)
                    handler(.success(movie))
                }
                catch {
                    handler(.failure(AnyError(error)))
                }
            }
        }
    }
}

//
//  SearchResult.swift
//  Movies
//
//  Created by Frederico Franco on 01/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//


struct SearchResult: Codable {
    
    let movies: [MovieSearchModel]
    let totalResults: String
    let response: String
    
    enum CodingKeys: String, CodingKey {
        case movies = "Search"
        case totalResults
        case response = "Response"
    }
}

struct MovieSearchModel: Codable {
    
    let title: String
    let year: String
    let imdbId: String
    let type: MediaType
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbId = "imdbID"
        case type = "Type"
        case poster = "Poster"
    }
}


enum MediaType: String, Codable {
    case series
    case movie
    case episode
    case game
}


/**
 Auxiliary type to work with integers that were represented with strings.
 See https://bugs.swift.org/browse/SR-5249 for further explanation.
 */
struct StringAsInt : Codable, RawRepresentable {
    
    let rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let value = Int(stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid integer string.")
        }
        
        self.rawValue = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(self.rawValue)")
    }
}

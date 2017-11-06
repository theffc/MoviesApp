//
//  MovieModel.swift
//  Movies
//
//  Created by Frederico Franco on 02/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import Foundation

struct MovieModel: Codable {
    
    // MARK: Essential
    
    let imdbId: String
    let title: String
    let year: String
    let poster: String
    let type: MediaType
    
    // MARK: About
    
    let rated: String
    let released: String
    let runtime: String
    let genre: String
    let director: String
    let writer: String
    let actors: String
    let plot: String
    let language: String
    let country: String
    
    // MARK: Critics
    
    let awards: String
    let ratings: [MovieRating]
    let metascore: String
    let imdbRating: String
    let imdbVotes: String
    
    // MARK: Optionals
    
    let dvd: String?
    let boxOffice: String?
    let production: String?
    let website: String?
    let totalSeasons: String?
    
    // MARK: -
    
    let response: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case rated = "Rated"
        case released = "Released"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case language = "Language"
        case country = "Country"
        case awards = "Awards"
        case poster = "Poster"
        case ratings = "Ratings"
        case metascore = "Metascore"
        case imdbRating = "imdbRating"
        case imdbVotes = "imdbVotes"
        case imdbId = "imdbID"
        case type = "Type"
        case dvd = "DVD"
        case boxOffice = "BoxOffice"
        case production = "Production"
        case website = "Website"
        case response = "Response"
        case totalSeasons
    }
}

enum MediaType: String, Codable {
    case series
    case movie
    case episode
    case game
}

struct MovieRating: Codable {

    let source: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}

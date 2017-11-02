//
//  OmdbApi.swift
//  Movies
//
//  Created by Frederico Franco on 01/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import Moya

fileprivate let apiKey = "201fefa"

enum OmdbApi {
    case movie(id: String)
    case searchMovie(title: String, page: Int)
}

extension OmdbApi: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://www.omdbapi.com/?apikey=\(apiKey)")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Method {
        return .get
    }
    
    var task: Task {
        switch self {
            
        case let .movie(id: id):
            return .requestParameters(parameters: ["i": id], encoding: URLEncoding.queryString)
            
        case let .searchMovie(title: title, page: page):
            return .requestParameters(parameters: ["s": title, "page": page], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
            
        case .movie(id: _):
            return movieSample
            
        case .searchMovie(title: _, page: _):
            return searchSample
        }
    }
}




// MARK: - Helpers

fileprivate extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

// search using the keyword "batman"
fileprivate var searchSample = """
{
    "Search": [
        {
            "Title": "Batman Begins",
            "Year": "2005",
            "imdbID": "tt0372784",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BNTM3OTc0MzM2OV5BMl5BanBnXkFtZTYwNzUwMTI3._V1_SX300.jpg"
        },
        {
            "Title": "Batman v Superman: Dawn of Justice",
            "Year": "2016",
            "imdbID": "tt2975590",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BYThjYzcyYzItNTVjNy00NDk0LTgwMWQtYjMwNmNlNWJhMzMyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg"
        },
        {
            "Title": "Batman",
            "Year": "1989",
            "imdbID": "tt0096895",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BMTYwNjAyODIyMF5BMl5BanBnXkFtZTYwNDMwMDk2._V1_SX300.jpg"
        },
        {
            "Title": "Batman Returns",
            "Year": "1992",
            "imdbID": "tt0103776",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BOGZmYzVkMmItM2NiOS00MDI3LWI4ZWQtMTg0YWZkODRkMmViXkEyXkFqcGdeQXVyODY0NzcxNw@@._V1_SX300.jpg"
        },
        {
            "Title": "Batman Forever",
            "Year": "1995",
            "imdbID": "tt0112462",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BNWY3M2I0YzItNzA1ZS00MzE3LThlYTEtMTg2YjNiOTYzODQ1XkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg"
        },
        {
            "Title": "Batman & Robin",
            "Year": "1997",
            "imdbID": "tt0118688",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BMGQ5YTM1NmMtYmIxYy00N2VmLWJhZTYtN2EwYTY3MWFhOTczXkEyXkFqcGdeQXVyNTA2NTI0MTY@._V1_SX300.jpg"
        },
        {
            "Title": "The LEGO Batman Movie",
            "Year": "2017",
            "imdbID": "tt4116284",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BMTcyNTEyOTY0M15BMl5BanBnXkFtZTgwOTAyNzU3MDI@._V1_SX300.jpg"
        },
        {
            "Title": "The LEGO Batman Movie",
            "Year": "2017",
            "imdbID": "tt4116284",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BMTcyNTEyOTY0M15BMl5BanBnXkFtZTgwOTAyNzU3MDI@._V1_SX300.jpg"
        },
        {
            "Title": "Batman: The Animated Series",
            "Year": "1992–1995",
            "imdbID": "tt0103359",
            "Type": "series",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BNzI5OWU0MjYtMmMwZi00YTRiLTljMDAtODQ0ZGYxMDljN2E0XkEyXkFqcGdeQXVyNTA4NzY1MzY@._V1_SX300.jpg"
        },
        {
            "Title": "Batman: Under the Red Hood",
            "Year": "2010",
            "imdbID": "tt1569923",
            "Type": "movie",
            "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BYTdlODI0YTYtNjk5ZS00YzZjLTllZjktYmYzNWM4NmI5MmMxXkEyXkFqcGdeQXVyNTA4NzY1MzY@._V1_SX300.jpg"
        }
    ],
    "totalResults": "334",
    "Response": "True"
}
""".utf8Encoded

fileprivate var movieSample = """
{
    "Title": "Batman",
    "Year": "1989",
    "Rated": "PG-13",
    "Released": "23 Jun 1989",
    "Runtime": "126 min",
    "Genre": "Action, Adventure",
    "Director": "Tim Burton",
    "Writer": "Bob Kane (Batman characters), Sam Hamm (story), Sam Hamm (screenplay), Warren Skaaren (screenplay)",
    "Actors": "Michael Keaton, Jack Nicholson, Kim Basinger, Robert Wuhl",
    "Plot": "The Dark Knight of Gotham City begins his war on crime with his first major enemy being the clownishly homicidal Joker.",
    "Language": "English, French",
    "Country": "USA, UK",
    "Awards": "Won 1 Oscar. Another 9 wins & 26 nominations.",
    "Poster": "https://images-na.ssl-images-amazon.com/images/M/MV5BMTYwNjAyODIyMF5BMl5BanBnXkFtZTYwNDMwMDk2._V1_SX300.jpg",
    "Ratings": [
        {
            "Source": "Internet Movie Database",
            "Value": "7.6/10"
        },
        {
            "Source": "Rotten Tomatoes",
            "Value": "72%"
        },
        {
            "Source": "Metacritic",
            "Value": "69/100"
        }
    ],
    "Metascore": "69",
    "imdbRating": "7.6",
    "imdbVotes": "289,519",
    "imdbID": "tt0096895",
    "Type": "movie",
    "DVD": "25 Mar 1997",
    "BoxOffice": "N/A",
    "Production": "Warner Bros. Pictures",
    "Website": "N/A",
    "Response": "True"
}
""".utf8Encoded

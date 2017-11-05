//
//  MovieDetailTableView.swift
//  Movies
//
//  Created by Frederico Franco on 05/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import Foundation

class MovieDetailField {
    
    let fieldName: String
    let fieldDescription: String
    
    init(name: String, description: String) {
        self.fieldName = name
        self.fieldDescription = description
    }
}

class MovieDetailFieldCell: UITableViewCell {
    
    @IBOutlet private weak var fieldNameLabel: UILabel!
    @IBOutlet private weak var fieldDescriptionLabel: UILabel!
    
    func updateView(for model: MovieDetailField) {
        fieldNameLabel.text = model.fieldName
        fieldDescriptionLabel.text = model.fieldDescription
    }
}

class MovieDetailTableSection {
    
    let fields: [MovieDetailField]
    
    let type: SectionType
    enum SectionType {
        case about
        case critics
    }
    
    init(fields: [MovieDetailField], type: SectionType) {
        self.fields = fields
        self.type = type
    }
    
    static func parseMovieModel(_ movie: MovieModel) -> [MovieDetailTableSection] {
        var sections = [MovieDetailTableSection]()
        sections.append(makeAboutSection(movie))
        sections.append(makeCriticsSection(movie))
        return sections
    }
    
    fileprivate static func makeAboutSection(_ movie: MovieModel) -> MovieDetailTableSection {
        var fields = [MovieDetailField]()
        fields.append(MovieDetailField(name: "Rated", description: movie.rated))
        fields.append(MovieDetailField(name: "Released", description: movie.released))
        fields.append(MovieDetailField(name: "Runtime", description: movie.runtime))
        fields.append(MovieDetailField(name: "Genre", description: movie.genre))
        fields.append(MovieDetailField(name: "Director", description: movie.director))
        fields.append(MovieDetailField(name: "Writer", description: movie.writer))
        fields.append(MovieDetailField(name: "Actors", description: movie.actors))
        fields.append(MovieDetailField(name: "Plot", description: movie.plot))
        fields.append(MovieDetailField(name: "Language", description: movie.language))
        fields.append(MovieDetailField(name: "Country", description: movie.country))
        
        return MovieDetailTableSection(fields: fields, type: .about)
    }
    
    fileprivate static func makeCriticsSection(_ movie: MovieModel) -> MovieDetailTableSection {
        var fields = [MovieDetailField]()
        fields.append(MovieDetailField(name: "Awards", description: movie.awards))
        fields.append(MovieDetailField(name: "Metascore", description: movie.metascore))
        fields.append(MovieDetailField(name: "Imdb Rating", description: movie.imdbRating))
        fields.append(MovieDetailField(name: "Imdb Votes", description: movie.imdbVotes))
        
        return MovieDetailTableSection(fields: fields, type: .critics)
    }
}

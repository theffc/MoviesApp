//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by Frederico Franco on 02/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import UIKit
import Result
import Moya

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


class MovieDetailViewController: UIViewController {

    var input: Input!
    enum Input {
        case completeMovie(MovieModel)
        case movieSearch(MovieSearchModel)
    }
    
    var provider: MovieModelProviderType = MovieModelRemoteProvider()
    
    static func staticInit(input: Input) -> MovieDetailViewController {
        guard let me = R.storyboard.main.movieDetailViewController() else {
            fatalError("Failed to retrieve view controller from storyboard")
        }
        
        me.input = input
        
        if case .movieSearch(_) = input {
            me.requestCompleteMovie()
        }
        
        return me
    }
    
    @IBOutlet private weak var headerView: MovieDetailHeaderView!
    @IBOutlet private weak var tableView: UITableView!
    
    
    
    var sections: [MovieDetailTableSection]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView(input: input)
    }
    
    func updateView(input: Input) {
        switch input {
        case let .completeMovie(movie):
            headerView.updateView(for: movie)
        case let .movieSearch(search):
            headerView.updateView(for: search)
            tableView.isHidden = true
        }
    }
    
    func requestCompleteMovie() {
        guard case let .movieSearch(search)? = input else {
            return
        }
        
        provider.requestMovie(id: search.imdbId) {
            [weak self] result in
            guard let weak = self else {
                return
            }
            
            switch result {
            case .failure(_):
                // TODO: Handle error
                fatalError("YOU SHOULD HAVE HANDLED THE ERROR")
            case let .success(movie):
                weak.input = .completeMovie(movie)
            }
        }
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

class MovieDetailHeaderView: UIView {
    
    @IBOutlet private weak var posterView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var mediaLabel: UILabel!
    
    func updateView(for search: MovieSearchModel) {
        posterView.sd_setImage(with: URL(string: search.poster), completed: nil)
        titleLabel.text = search.title
        yearLabel.text = search.year
        mediaLabel.text = search.type.rawValue.capitalized
    }
    
    func updateView(for movie: MovieModel) {
        posterView.sd_setImage(with: URL(string: movie.poster), completed: nil)
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        mediaLabel.text = movie.type.rawValue.capitalized
    }
}

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

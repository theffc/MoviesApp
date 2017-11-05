//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by Frederico Franco on 02/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

import UIKit


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

//
//  Loadable.swift
//  Movies
//
//  Created by Frederico Franco on 04/11/17.
//  Copyright © 2017 Frederico Franco. All rights reserved.
//

enum Loadable<Value, E: Error> {
    
    case loading
    case loaded(Value)
    case error(E)
}

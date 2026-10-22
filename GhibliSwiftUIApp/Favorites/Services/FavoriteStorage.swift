//
//  FavoriteStorage.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import Foundation

protocol FavoriteStorage {
    func load() -> Set<String>
    func save(favoriteIDs: Set<String>)
}

//
//  GhibliService.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 04/08/2026.
//

import Foundation

protocol GhibliService : Sendable {
    func fetchFilms() async throws -> [Film]
    func fetchPerson(from URLString: String) async throws -> Person
}

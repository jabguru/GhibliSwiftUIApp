//
//  SearchScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

struct SearchScreen: View {

    @State private var text: String = ""
    @State private var searchViewModel: SearchFilmsViewModel
    let favoritesViewModel: FavoritesViewModel

    init(favoritesViewModel: FavoritesViewModel,
         service: GhibliService = DefaultGhibliService()) {
        self.favoritesViewModel = favoritesViewModel
        self.searchViewModel = SearchFilmsViewModel(service: service)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch searchViewModel.state {
                    case .idle:
                        AnimatedStateView(systemImage: "sparkle.magnifyingglass",
                                          title: "Find a film",
                                          message: "Search by title, like “Totoro” or “Spirited Away”.")
                    case .loading:
                        SkeletonGrid()
                    case .error(let error):
                        AnimatedStateView(systemImage: "exclamationmark.icloud",
                                          title: "Search failed",
                                          message: error)
                    case .loaded(let films) where films.isEmpty:
                        AnimatedStateView(systemImage: "wind",
                                          title: "Nothing here",
                                          message: "No film matches “\(text)”. Try another title.")
                    case .loaded(let films):
                        FilmListView(films: films,
                                     favoritesViewModel: favoritesViewModel)
                }
            }
            .animation(.smooth(duration: 0.35), value: searchViewModel.state)
            .background { AnimatedBackground() }
            .navigationTitle("Search Ghibli Movies")
            .searchable(text: $text)
            .task(id: text) {
                await searchViewModel.fetch(for: text)
            }
        }
    }
}

#Preview {
    SearchScreen(favoritesViewModel: FavoritesViewModel(service: MockFavoriteStorage()),
                 service: MockGhibliService())
        .ghibliTheme()
}

//
//  FavoritesScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

struct FavoritesScreen: View {

    let filmsViewModel: FilmsViewModel
    let favoritesViewModel: FavoritesViewModel

    var films: [Film] {
       let favorites = favoritesViewModel.favoriteIDs
        switch filmsViewModel.state {
            case .loaded(let films):
                return films.filter { favorites.contains($0.id) }
            default: return []
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if films.isEmpty {
                    AnimatedStateView(systemImage: "heart.circle",
                                      title: "No favorites yet",
                                      message: "Tap the heart on any film and it will float over here.")
                    .transition(.blurReplace)
                } else {
                    FilmListView(films: films,
                                 favoritesViewModel: favoritesViewModel)
                }
            }
            // Removing the last favorite smoothly swaps the grid for the empty state.
            .animation(.smooth, value: films.isEmpty)
            .background { AnimatedBackground() }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesScreen(filmsViewModel: FilmsViewModel.example,
                    favoritesViewModel: FavoritesViewModel.example)
        .ghibliTheme()
}

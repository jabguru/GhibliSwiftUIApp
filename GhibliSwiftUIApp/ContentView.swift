//
//  ContentView.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 01/08/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var filmsViewModel = FilmsViewModel()
    @State private var favoritesViewModel = FavoritesViewModel()
    
    var body: some View {
        TabView {
            Tab("Movies", systemImage: "movieclapper") {
                FilmsScreen(filmsViewModel: filmsViewModel,
                            favoritesViewModel: favoritesViewModel)
            }
            
            Tab("Favorites", systemImage: "heart") {
                FavoritesScreen(filmsViewModel: filmsViewModel,
                                favoritesViewModel: favoritesViewModel)
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsScreen()
            }
            
            Tab(role: .search) {
                SearchScreen(favoritesViewModel: favoritesViewModel)
            }
        }
        .task {
            favoritesViewModel.load()
            await filmsViewModel.fetch()
        }
        // Picks the pastel or cinematic theme from light/dark mode and shares it with every screen.
        .ghibliTheme()
        .setAppearanceTheme()
    }
}

#Preview {
    ContentView()
}

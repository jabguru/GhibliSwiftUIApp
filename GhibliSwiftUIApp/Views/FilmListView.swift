//
//  FilmListView.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 01/08/2026.
//

import SwiftUI

/// What we push onto the navigation stack: the film plus the ID of the card it was tapped
/// from, so the zoom transition knows which card to grow out of.
struct FilmRoute: Hashable {
    let film: Film
    let sourceID: String
}

/// A scrolling poster grid with an optional header above it.
///
/// `Header` is a generic view type, the same idea as a Flutter widget taking a
/// `Widget header` parameter. The header receives the zoom namespace so it can host
/// its own transition sources (the hero carousel does).
struct FilmListView<Header: View>: View {

    var films: [Film]
    let favoritesViewModel: FavoritesViewModel
    private let header: (Namespace.ID) -> Header

    // Flutter: a `@Namespace` is like the shared `tag` space for `Hero` widgets.
    // Views that share an ID inside it can morph into each other.
    @Namespace private var zoomNamespace

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    init(films: [Film],
         favoritesViewModel: FavoritesViewModel,
         @ViewBuilder header: @escaping (Namespace.ID) -> Header) {
        self.films = films
        self.favoritesViewModel = favoritesViewModel
        self.header = header
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header(zoomNamespace)

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(Array(films.enumerated()), id: \.element.id) { index, film in
                        cell(for: film)
                            .staggeredAppear(index: index)
                            // How a card enters/leaves when the array changes, e.g.
                            // un-favoriting on the Favorites tab. Flutter: `AnimatedList`.
                            .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity),
                                                    removal: .scale(scale: 0.5).combined(with: .opacity)))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .navigationDestination(for: FilmRoute.self) { route in
            FilmDetailScreen(film: route.film,
                             favoritesViewModel: favoritesViewModel)
                // Flutter: `Hero` / `OpenContainer`. The detail screen zooms out of the tapped card
                // and, on a back swipe, shrinks back into it interactively.
                .navigationTransition(.zoom(sourceID: route.sourceID, in: zoomNamespace))
        }
    }

    private func cell(for film: Film) -> some View {
        let sourceID = "grid-\(film.id)"
        return NavigationLink(value: FilmRoute(film: film, sourceID: sourceID)) {
            FilmCard(film: film)
                .matchedTransitionSource(id: sourceID, in: zoomNamespace)
        }
        .buttonStyle(.pressable)
        // The heart sits on top of the link rather than inside it, so tapping it
        // doesn't also open the detail screen.
        .overlay(alignment: .topTrailing) {
            FavoriteButton(filmID: film.id,
                           favoritesViewModel: favoritesViewModel,
                           showsBackground: true)
                .padding(8)
        }
    }
}

extension FilmListView where Header == EmptyView {
    /// A plain grid with no header.
    init(films: [Film], favoritesViewModel: FavoritesViewModel) {
        self.init(films: films, favoritesViewModel: favoritesViewModel) { _ in EmptyView() }
    }
}

#Preview {
    @Previewable @State var favorites = FavoritesViewModel(service: MockFavoriteStorage())

    NavigationStack {
        FilmListView(films: [Film.example, Film.exampleFavorite],
                     favoritesViewModel: favorites)
    }
    .ghibliTheme()
    .task {
        favorites.load()
    }
}

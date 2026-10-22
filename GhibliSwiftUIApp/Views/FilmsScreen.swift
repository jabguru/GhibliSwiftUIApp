//
//  FilmsScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

struct FilmsScreen: View {

    let filmsViewModel: FilmsViewModel
    let favoritesViewModel: FavoritesViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch filmsViewModel.state {
                    case .idle, .loading:
                        SkeletonGrid(showsHero: true)

                    case .loaded(let films):
                        FilmListView(films: films,
                                     favoritesViewModel: favoritesViewModel) { namespace in
                            VStack(spacing: 16) {
                                GreetingHeader()
                                HeroCarousel(films: topRated(films), namespace: namespace)
                                SectionHeader(title: "All films")
                                    .padding(.horizontal)
                            }
                        }

                    case .error(let error):
                        AnimatedStateView(systemImage: "cloud.bolt.rain",
                                          title: "Lost in the clouds",
                                          message: error,
                                          actionTitle: "Try again") {
                            Task { await filmsViewModel.fetch() }
                        }
                }
            }
            // `LoadingState` is Equatable, so one line cross-fades between
            // skeleton, content and error whenever the state changes.
            .animation(.smooth(duration: 0.45), value: filmsViewModel.state)
            .background { AnimatedBackground() }
            .navigationTitle("Ghibli Movies")
        }
    }

    /// The six highest-rated films for the carousel.
    private func topRated(_ films: [Film]) -> [Film] {
        Array(films.sorted { (Int($0.score) ?? 0) > (Int($1.score) ?? 0) }.prefix(6))
    }
}

/// "Good evening, Julius": greets the user by time of day, using the name from Settings.
private struct GreetingHeader: View {

    @Environment(\.theme) private var theme
    @AppStorage(UserDefaultsKeys.username) private var username: String = ""

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
            case 5..<12: "Good morning"
            case 12..<18: "Good afternoon"
            default: "Good evening"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(username.isEmpty ? greeting : "\(greeting), \(username)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.textSecondary)
            Text("Top rated tonight")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

#Preview {
    FilmsScreen(filmsViewModel: FilmsViewModel.example, favoritesViewModel: FavoritesViewModel.example)
        .ghibliTheme()
}

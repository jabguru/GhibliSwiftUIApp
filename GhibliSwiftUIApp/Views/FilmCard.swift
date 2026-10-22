//
//  FilmCard.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

/// A poster card: artwork, a dark scrim and the title on top.
struct FilmCard: View {

    @Environment(\.theme) private var theme

    let film: Film

    var body: some View {
        // `Color.clear` with an aspect ratio is a handy way to make a sized box
        // (Flutter: `AspectRatio(aspectRatio: 2 / 3)`) that you then layer onto with overlays.
        Color.clear
            .aspectRatio(2 / 3, contentMode: .fit)
            .overlay { FilmImageView(urlPath: film.image) }
            .overlay { theme.posterScrim }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(film.title)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .lineLimit(2)
                    Text("\(film.releaseYear) · \(film.director)")
                        .font(.caption)
                        .opacity(0.8)
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(12)
            }
            .clipShape(.rect(cornerRadius: theme.cardRadius))
            .overlay {
                // A hairline border helps cards stand out on any background.
                RoundedRectangle(cornerRadius: theme.cardRadius)
                    .strokeBorder(.white.opacity(theme.isDark ? 0.12 : 0.6), lineWidth: 1)
            }
            .shadow(color: .black.opacity(theme.isDark ? 0.5 : 0.15), radius: 14, y: 8)
    }
}

#Preview {
    FilmCard(film: Film.exampleFavorite)
        .frame(width: 180)
        .padding()
}

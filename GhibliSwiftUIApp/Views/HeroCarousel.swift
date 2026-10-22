//
//  HeroCarousel.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

/// A paging carousel of wide banner cards with a 3D tilt, parallax artwork,
/// animated page dots and auto-advance.
struct HeroCarousel: View {

    @Environment(\.theme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let films: [Film]
    /// The zoom-transition namespace owned by `FilmListView`.
    let namespace: Namespace.ID

    /// The film currently snapped into view. Two-way bound to the scroll position.
    @State private var currentID: String?

    var body: some View {
        VStack(spacing: 14) {
            // Flutter: this whole block is a `PageView` with `viewportFraction`, but built
            // from a normal horizontal ScrollView plus a snapping behavior.
            ScrollView(.horizontal) {
                LazyHStack(spacing: 14) {
                    ForEach(films) { film in
                        let sourceID = "hero-\(film.id)"
                        NavigationLink(value: FilmRoute(film: film, sourceID: sourceID)) {
                            HeroCard(film: film)
                                .matchedTransitionSource(id: sourceID, in: namespace)
                        }
                        .buttonStyle(.pressable)
                        // Each page is the width of the scroll view (minus the content margins).
                        .containerRelativeFrame(.horizontal)
                        // `scrollTransition` hands you `phase.value`: -1 (off to the left),
                        // 0 (centered) and 1 (off to the right). Map it to any effect you like.
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(1 - abs(phase.value) * 0.08)
                                .rotation3DEffect(.degrees(phase.value * -14),
                                                  axis: (x: 0, y: 1, z: 0),
                                                  perspective: 0.5)
                                .opacity(1 - abs(phase.value) * 0.4)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 20, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentID)
            .scrollIndicators(.hidden)
            // Scroll views clip their content by default, which would cut the card shadows off.
            .scrollClipDisabled()
            .frame(height: 220)

            PageDots(films: films, currentID: currentID ?? films.first?.id)
        }
        // Flutter: like `Timer.periodic` started in `initState` and cancelled in `dispose`.
        // `.task` is cancelled automatically when the view disappears.
        .task {
            guard !reduceMotion else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                withAnimation(.smooth(duration: 0.8)) {
                    currentID = nextID()
                }
            }
        }
    }

    private func nextID() -> String? {
        guard let index = films.firstIndex(where: { $0.id == currentID }) else {
            return films.dropFirst().first?.id
        }
        return films[(index + 1) % films.count].id
    }
}

// MARK: - Card

private struct HeroCard: View {

    @Environment(\.theme) private var theme

    let film: Film

    var body: some View {
        FilmImageView(urlPath: film.bannerImage)
            // Make the artwork larger than the card, then slide it against the scroll
            // direction. The image moves slower than its frame, which reads as depth (parallax).
            .scaleEffect(1.3)
            .scrollTransition(axis: .horizontal) { content, phase in
                content.offset(x: phase.value * -50)
            }
            .overlay { theme.posterScrim }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("\(film.score)", systemImage: "star.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        // Liquid Glass (iOS 26). Flutter: `BackdropFilter` + a translucent
                        // container, but it also refracts light and reacts to touches.
                        .glassEffect(.regular, in: .capsule)

                    Text(film.title)
                        .font(.system(.title2, design: .rounded, weight: .heavy))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(film.description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(2)
                }
                .padding(18)
            }
            .clipShape(.rect(cornerRadius: 26))
            .shadow(color: theme.accent.opacity(theme.isDark ? 0.35 : 0.25), radius: 18, y: 10)
    }
}

// MARK: - Page dots

private struct PageDots: View {

    @Environment(\.theme) private var theme

    let films: [Film]
    let currentID: String?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(films) { film in
                let isCurrent = film.id == currentID
                Capsule()
                    .fill(isCurrent ? AnyShapeStyle(theme.accentGradient)
                                    : AnyShapeStyle(theme.textSecondary.opacity(0.3)))
                    .frame(width: isCurrent ? 22 : 7, height: 7)
            }
        }
        // Flutter: `AnimatedContainer`. Width and color animate whenever the page changes.
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentID)
    }
}

#Preview {
    @Previewable @Namespace var namespace

    NavigationStack {
        HeroCarousel(films: [Film.example, Film.exampleFavorite], namespace: namespace)
    }
}

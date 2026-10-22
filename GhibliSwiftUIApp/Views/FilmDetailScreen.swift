//
//  FilmDetailScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 08/08/2026.
//

import SwiftUI

struct FilmDetailScreen: View {

    let film: Film
    let favoritesViewModel: FavoritesViewModel

    @State private var viewModel = FilmDetailViewModel()

    /// How far the content has scrolled: 0 at rest, negative when pulled down, positive when scrolled up.
    @State private var scrollOffset: CGFloat = 0

    private let bannerHeight: CGFloat = 360

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                StretchyBanner(urlPath: film.bannerImage,
                               height: bannerHeight,
                               scrollOffset: scrollOffset)

                TitleHeader(film: film)
                    // Negative padding pulls the header up so the poster overlaps the banner.
                    .padding(.top, -120)

                Group {
                    InfoChips(film: film)
                    DescriptionSection(text: film.description)
                    CharacterSectionView(viewModel: viewModel)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        // Flutter: like a `ScrollController` listener. We read the scroll position
        // and feed it into the banner to stretch it and move it at a slower speed (parallax).
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, newValue in
            scrollOffset = newValue
        }
        .background { AnimatedBackground() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // The title fades into the bar once the big title has scrolled away.
            ToolbarItem(placement: .principal) {
                Text(film.title)
                    .font(.headline)
                    .opacity(scrollOffset > bannerHeight ? 1 : 0)
                    .animation(.smooth, value: scrollOffset > bannerHeight)
            }
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(filmID: film.id,
                               favoritesViewModel: favoritesViewModel)
            }
        }
        .task(id: film) {
            await viewModel.fetch(for: film)
        }
    }
}

// MARK: - Stretchy banner

/// Flutter: `SliverAppBar(stretch: true)` with a parallax `FlexibleSpaceBar`.
private struct StretchyBanner: View {

    let urlPath: String
    let height: CGFloat
    let scrollOffset: CGFloat

    private var pull: CGFloat { max(0, -scrollOffset) }

    var body: some View {
        // The layout slot always stays `height` tall. Only the drawn image changes.
        Color.clear
            .frame(height: height)
            .overlay(alignment: .top) {
                FilmImageView(urlPath: urlPath)
                    // Pulled down: grow taller and stay pinned to the top edge.
                    // Scrolled up: move down at half speed, so it lags behind the content.
                    .frame(height: height + pull)
                    .offset(y: scrollOffset < 0 ? scrollOffset : scrollOffset * 0.5)
                    .blur(radius: min(max(0, scrollOffset) / 25, 10))
                    // Melts the image into whatever is behind it. A mask uses only the
                    // gradient's alpha: opaque keeps the pixels, clear erases them.
                    // Flutter: `ShaderMask` with a `LinearGradient`.
                    .mask {
                        LinearGradient(colors: [.black, .black, .clear],
                                       startPoint: .top,
                                       endPoint: .bottom)
                    }
            }
    }
}

// MARK: - Poster and title

private struct TitleHeader: View {

    @Environment(\.theme) private var theme

    let film: Film

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            FilmImageView(urlPath: film.image)
                .frame(width: 120, height: 180)
                .clipShape(.rect(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.35), radius: 16, y: 10)
                .staggeredAppear(index: 1)

            VStack(alignment: .leading, spacing: 6) {
                Text(film.title)
                    .font(.system(.title, design: .rounded, weight: .heavy))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)

                Text("Directed by \(film.director)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(.bottom, 8)
            .staggeredAppear(index: 2)
        }
        .padding(.horizontal)
    }
}

// MARK: - Info chips

private struct InfoChips: View {

    let film: Film

    var body: some View {
        // `GlassEffectContainer` lets neighbouring glass shapes share one rendering pass and
        // blend into each other when they get close, like liquid drops merging.
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                InfoChip(label: "Score") {
                    ScoreRing(score: Int(film.score) ?? 0)
                        .frame(width: 54, height: 54)
                }
                InfoChip(label: "Released") {
                    ChipValue(systemImage: "calendar", value: film.releaseYear)
                }
                InfoChip(label: "Runtime") {
                    ChipValue(systemImage: "clock", value: "\(film.duration)m")
                }
            }
        }
        .staggeredAppear(index: 3)
    }
}

private struct InfoChip<Content: View>: View {

    @Environment(\.theme) private var theme

    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 8) {
            content
                .frame(height: 58)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .rect(cornerRadius: theme.chipRadius + 6))
    }
}

private struct ChipValue: View {

    @Environment(\.theme) private var theme

    let systemImage: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(theme.accentGradient)
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(theme.textPrimary)
        }
    }
}

// MARK: - Description

private struct DescriptionSection: View {

    @Environment(\.theme) private var theme

    let text: String

    @State private var isExpanded = false

    private var isLong: Bool { text.count > 180 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Story")

            Text(text)
                .font(.body)
                .foregroundStyle(theme.textPrimary.opacity(0.85))
                .lineSpacing(4)
                .lineLimit(isExpanded ? nil : 4)

            if isLong {
                Button {
                    // Explicit animation: wrap the state change and SwiftUI animates every view
                    // affected by it. Here that's the text height and the chevron rotation.
                    withAnimation(.snappy) { isExpanded.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Show less" : "Read more")
                            .contentTransition(.interpolate)
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.accent)
                }
                .buttonStyle(.pressable)
            }
        }
        .staggeredAppear(index: 4)
    }
}

// MARK: - Characters

fileprivate struct CharacterSectionView: View {

    @Environment(\.theme) private var theme

    let viewModel: FilmDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Characters")

            Group {
                switch viewModel.state {
                    case .idle, .loading:
                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { _ in
                                SkeletonBlock(cornerRadius: 20)
                                    .frame(width: 130, height: 150)
                            }
                        }

                    case .loaded(let people) where people.isEmpty:
                        unavailable

                    case .loaded(let people):
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                                    CharacterCard(person: person)
                                        .staggeredAppear(index: index)
                                        .scrollTransition(axis: .horizontal) { content, phase in
                                            content
                                                .scaleEffect(phase.isIdentity ? 1 : 0.88)
                                                .opacity(phase.isIdentity ? 1 : 0.6)
                                        }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .scrollIndicators(.hidden)
                        // Lets cards scroll edge to edge while still lining up with the page padding.
                        .scrollClipDisabled()

                    case .error:
                        unavailable
                }
            }
            .animation(.smooth, value: viewModel.state)
        }
        .staggeredAppear(index: 5)
    }

    private var unavailable: some View {
        Label("Character details aren't available for this film.", systemImage: "person.crop.circle.badge.questionmark")
            .font(.subheadline)
            .foregroundStyle(theme.textSecondary)
    }
}

private struct CharacterCard: View {

    @Environment(\.theme) private var theme

    let person: Person

    private var initials: String {
        person.name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
    }

    /// A stable color per character, picked from the name.
    private var avatarColors: [Color] {
        let palettes: [[Color]] = [
            [Color(hex: 0x6FA8DC), Color(hex: 0x3E8E7E)],
            [Color(hex: 0xE76F8A), Color(hex: 0xF4B860)],
            [Color(hex: 0x7B5CFF), Color(hex: 0xE76F8A)],
            [Color(hex: 0x3E8E7E), Color(hex: 0xF4B860)],
        ]
        let hash = person.name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palettes[hash % palettes.count]
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(initials)
                .font(.system(.title2, design: .rounded, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(LinearGradient(colors: avatarColors,
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            in: Circle())
                .shadow(color: avatarColors[0].opacity(0.5), radius: 8, y: 4)

            Text(person.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)

            Text("\(person.gender) · \(person.age)")
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 130, height: 150)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        FilmDetailScreen(film: Film.exampleFavorite,
                         favoritesViewModel: FavoritesViewModel(service: MockFavoriteStorage()))
    }
    .ghibliTheme()
}

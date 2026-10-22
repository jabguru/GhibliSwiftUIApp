//
//  FavoriteButton.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

struct FavoriteButton: View {

    @Environment(\.theme) private var theme

    let filmID: String
    let favoritesViewModel: FavoritesViewModel
    /// Draws a frosted glass circle behind the heart, for use on top of images.
    var showsBackground: Bool = false

    /// Bumped each time the film becomes a favorite, which replays the burst.
    @State private var burstTrigger = 0

    var isFavorite: Bool {
        favoritesViewModel.isFavorite(filmID: filmID)
    }

    var body: some View {
        Button {
            // Flutter: like calling setState inside an animation scope. Every view that
            // depends on the favorites list (e.g. the Favorites grid) animates the change.
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                favoritesViewModel.toggleFavorite(filmID: filmID)
            }
            if isFavorite { burstTrigger += 1 }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isFavorite ? theme.favorite : (showsBackground ? .white : theme.textSecondary))
                // SF Symbols have built-in animations: morph between outline and filled…
                .contentTransition(.symbolEffect(.replace))
                // …and bounce whenever the value changes.
                .symbolEffect(.bounce, value: isFavorite)
                .frame(width: 36, height: 36)
                .background {
                    if showsBackground {
                        Circle().fill(.ultraThinMaterial)
                    }
                }
                .overlay { HeartBurst(color: theme.favorite, trigger: burstTrigger) }
                .contentShape(Circle())
        }
        .buttonStyle(.pressable)
        // Flutter: `HapticFeedback.mediumImpact()`, but declarative: fires when `isFavorite` changes.
        .sensoryFeedback(.impact(weight: .medium), trigger: isFavorite)
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }
}

// MARK: - Particle burst

/// The values the keyframes animate. Each property gets its own track and timing.
private struct BurstValues {
    var radius: CGFloat = 0
    var scale: CGFloat = 0.3
    var opacity: Double = 0
}

/// A ring of tiny hearts that shoots outwards and fades.
private struct HeartBurst: View {
    let color: Color
    let trigger: Int

    private let count = 8

    var body: some View {
        // Flutter: `KeyframeAnimator` is like a `TweenSequence` per property, all driven by one
        // controller. When `trigger` changes it plays from `initialValue`, then settles back there.
        KeyframeAnimator(initialValue: BurstValues(), trigger: trigger) { values in
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    let angle = Double(index) / Double(count) * 2 * .pi
                    Image(systemName: "heart.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(color)
                        .scaleEffect(values.scale)
                        .offset(x: cos(angle) * values.radius,
                                y: sin(angle) * values.radius)
                }
            }
            .opacity(values.opacity)
        } keyframes: { _ in
            KeyframeTrack(\.radius) {
                SpringKeyframe(26, duration: 0.5, spring: .bouncy)
            }
            KeyframeTrack(\.scale) {
                CubicKeyframe(1.2, duration: 0.25)
                CubicKeyframe(0.5, duration: 0.35)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(1, duration: 0.05)
                LinearKeyframe(1, duration: 0.25)
                LinearKeyframe(0, duration: 0.3)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    @Previewable @State var favorites = FavoritesViewModel(service: MockFavoriteStorage())

    HStack(spacing: 40) {
        FavoriteButton(filmID: "1", favoritesViewModel: favorites)
        FavoriteButton(filmID: "2", favoritesViewModel: favorites, showsBackground: true)
            .padding()
            .background(.indigo.gradient, in: .rect(cornerRadius: 16))
    }
    .scaleEffect(2)
}

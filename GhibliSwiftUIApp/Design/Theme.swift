//
//  Theme.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

// Flutter: this is your `ThemeData`. A plain value type holding every design token,
// so views never hard-code colors or radii.
struct GhibliTheme {
    enum Style { case pastel, cinematic }

    let style: Style

    // Palette
    let accent: Color
    let accentSecondary: Color
    let favorite: Color
    let textPrimary: Color
    let textSecondary: Color
    let cardSurface: Color
    let skeleton: Color

    // Background mesh (3x3 grid of colors, see AnimatedBackground)
    let meshColors: [Color]

    // Shape tokens
    let cardRadius: CGFloat = 22
    let chipRadius: CGFloat = 14

    var isDark: Bool { style == .cinematic }

    /// Fades the bottom of a poster into a readable scrim.
    var posterScrim: LinearGradient {
        LinearGradient(colors: [.clear, .black.opacity(isDark ? 0.85 : 0.65)],
                       startPoint: .center,
                       endPoint: .bottom)
    }

    var accentGradient: LinearGradient {
        LinearGradient(colors: [accent, accentSecondary],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    // MARK: - The two themes

    /// Light mode: soft watercolor sky and meadow.
    static let pastel = GhibliTheme(
        style: .pastel,
        accent: Color(hex: 0x3E8E7E),          // meadow green
        accentSecondary: Color(hex: 0x6FA8DC), // sky blue
        favorite: Color(hex: 0xE76F8A),
        textPrimary: Color(hex: 0x23323A),
        textSecondary: Color(hex: 0x5E6E76),
        cardSurface: Color.white.opacity(0.75),
        skeleton: Color(hex: 0xDCE7EA),
        meshColors: [
            Color(hex: 0xBFE3F7), Color(hex: 0xD8EEFA), Color(hex: 0xFFF6E0),
            Color(hex: 0xCDEBF5), Color(hex: 0xF4F9F1), Color(hex: 0xFDEFD9),
            Color(hex: 0xD6EDCF), Color(hex: 0xE5F3D8), Color(hex: 0xF7F0DA),
        ]
    )

    /// Dark mode: a cinema at night with glowing accents.
    static let cinematic = GhibliTheme(
        style: .cinematic,
        accent: Color(hex: 0xF4B860),          // lantern gold
        accentSecondary: Color(hex: 0xE76F8A), // sunset pink
        favorite: Color(hex: 0xFF5C8A),
        textPrimary: .white,
        textSecondary: Color.white.opacity(0.65),
        cardSurface: Color.white.opacity(0.08),
        skeleton: Color.white.opacity(0.10),
        meshColors: [
            Color(hex: 0x0B0E1A), Color(hex: 0x141933), Color(hex: 0x0B0E1A),
            Color(hex: 0x1B1640), Color(hex: 0x2A1B4D), Color(hex: 0x10162E),
            Color(hex: 0x080A14), Color(hex: 0x1A1030), Color(hex: 0x080A14),
        ]
    )

    static func forScheme(_ scheme: ColorScheme) -> GhibliTheme {
        scheme == .dark ? .cinematic : .pastel
    }
}

// Flutter: `Theme.of(context)`. `@Entry` adds a value to SwiftUI's environment, which
// works like an InheritedWidget: set it once near the root, then read it anywhere below
// with `@Environment(\.theme) private var theme`.
extension EnvironmentValues {
    @Entry var theme: GhibliTheme = .pastel
}

extension View {
    /// Picks the theme from the current light/dark scheme and injects it for all child views.
    func ghibliTheme() -> some View {
        modifier(ThemeInjector())
    }
}

private struct ThemeInjector: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let theme = GhibliTheme.forScheme(colorScheme)
        content
            .environment(\.theme, theme)
            .tint(theme.accent)
    }
}

extension Color {
    /// `Color(hex: 0x3E8E7E)`, the same as Flutter's `Color(0xFF3E8E7E)` without the alpha byte.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

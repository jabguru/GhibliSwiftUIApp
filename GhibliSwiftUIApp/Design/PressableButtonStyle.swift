//
//  PressableButtonStyle.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

// Flutter: a `ButtonStyle` is like wrapping a child in `GestureDetector` + `AnimatedScale`,
// except SwiftUI tells you `isPressed` for free. Apply it to a whole subtree with
// `.buttonStyle(.pressable)` and every `Button` inside picks it up.
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            // Implicit animation: whenever `isPressed` changes, animate the modifiers above it.
            // Flutter: the same idea as `AnimatedContainer`.
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
}

/// A rounded, gradient-filled call-to-action button label.
struct PillButtonLabel: View {
    @Environment(\.theme) private var theme

    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(theme.accentGradient, in: Capsule())
            .shadow(color: theme.accent.opacity(0.4), radius: 12, y: 6)
    }
}

#Preview {
    Button {} label: {
        PillButtonLabel(title: "Try again", systemImage: "arrow.clockwise")
    }
    .buttonStyle(.pressable)
}

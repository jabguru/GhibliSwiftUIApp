//
//  Shimmer.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

// Flutter: a `ViewModifier` is a reusable wrapper widget. Write it once, then call it like
// a method: `.shimmer()`. It's the idiomatic way to package up "behavior + decoration".
struct Shimmer: ViewModifier {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                // A diagonal band of light that sweeps from left to right.
                LinearGradient(colors: [.clear, .white.opacity(0.45), .clear],
                               startPoint: .leading,
                               endPoint: .trailing)
                    .rotationEffect(.degrees(20))
                    // `visualEffect` gives you the view's size without a GeometryReader,
                    // so the band can travel exactly one width.
                    .visualEffect { [phase] content, proxy in
                        content.offset(x: phase * proxy.size.width * 1.5)
                    }
                    .blendMode(.plusLighter)
            }
            .clipped()
            .onAppear {
                guard !reduceMotion else { return }
                // Flutter: `controller.repeat()`. An explicit animation that loops forever.
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}

/// A placeholder block for skeleton loaders.
struct SkeletonBlock: View {
    @Environment(\.theme) private var theme
    var cornerRadius: CGFloat = 12

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(theme.skeleton)
            .shimmer()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(alignment: .leading) {
        SkeletonBlock(cornerRadius: 22)
            .frame(height: 220)
        SkeletonBlock()
            .frame(width: 160, height: 16)
    }
    .padding()
}

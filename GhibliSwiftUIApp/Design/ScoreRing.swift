//
//  ScoreRing.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

// Flutter: a custom `Shape` is a `CustomPainter` that SwiftUI knows how to animate.
// The trick is `animatableData`: SwiftUI interpolates this value frame by frame
// (like a `Tween`) and redraws the path at every step.
//
// `nonisolated`: this project runs everything on the main actor by default, but
// SwiftUI may compute shape paths off the main thread, so shapes must opt out.
nonisolated struct ArcShape: Shape {
    var progress: Double // 0...1

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: min(rect.width, rect.height) / 2,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-90 + 360 * progress),
                    clockwise: false)
        return path
    }
}

/// A circular score meter that sweeps from 0 to the score and counts up as it goes.
struct ScoreRing: View {

    @Environment(\.theme) private var theme

    let score: Int // 0...100
    var lineWidth: CGFloat = 7

    @State private var displayedScore = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(theme.textSecondary.opacity(0.2), lineWidth: lineWidth)

            ArcShape(progress: Double(displayedScore) / 100)
                .stroke(AngularGradient(colors: [theme.accentSecondary, theme.accent, theme.accentSecondary],
                                        center: .center),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

            Text("\(displayedScore)")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(theme.textPrimary)
                // Animates the digits rolling like an odometer whenever the number changes.
                .contentTransition(.numericText(value: Double(displayedScore)))
        }
        .padding(lineWidth / 2)
        .onAppear {
            // One state change, two animations: the arc (via animatableData)
            // and the text (via contentTransition) both follow this curve.
            withAnimation(.easeOut(duration: 1.4).delay(0.3)) {
                displayedScore = score
            }
        }
    }
}

#Preview {
    ScoreRing(score: 93)
        .frame(width: 70, height: 70)
        .padding()
}

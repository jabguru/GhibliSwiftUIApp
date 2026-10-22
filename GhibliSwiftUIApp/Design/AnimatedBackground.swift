//
//  AnimatedBackground.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

/// A living backdrop that never stops moving: a slowly breathing mesh gradient,
/// with drifting clouds (light mode) or twinkling stars (dark mode) painted on top.
struct AnimatedBackground: View {

    @Environment(\.theme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Flutter: `TimelineView` is like an `AnimationController` driven by a `Ticker`.
        // It rebuilds its content every frame and hands you the current time,
        // so you compute positions as pure functions of `t`. No state is needed.
        TimelineView(.animation(paused: reduceMotion)) { context in
            let t = context.date.timeIntervalSinceReferenceDate

            ZStack {
                MeshGradient(width: 3,
                             height: 3,
                             points: meshPoints(at: t),
                             colors: theme.meshColors)

                if theme.isDark {
                    StarField(time: t)
                } else {
                    CloudLayer(time: t)
                }
            }
        }
        .ignoresSafeArea()
    }

    /// A 3x3 grid of control points. The corners stay pinned and the middle points wobble,
    /// which makes the colors flow like watercolor.
    private func meshPoints(at t: Double) -> [SIMD2<Float>] {
        let w = Float(sin(t * 0.35) * 0.12)
        let v = Float(cos(t * 0.27) * 0.10)
        return [
            [0, 0],           [0.5 + w, 0],       [1, 0],
            [0, 0.5 + v],     [0.5 - v, 0.5 + w], [1, 0.5 - w],
            [0, 1],           [0.5 + v, 1],       [1, 1],
        ]
    }
}

// MARK: - Clouds (light mode)

// Flutter: `Canvas` is SwiftUI's `CustomPainter`. You draw paths imperatively into a
// graphics context, and it's far cheaper than building hundreds of views.
private struct CloudLayer: View {
    let time: Double

    // (vertical position, scale, speed, phase offset)
    private let clouds: [(y: Double, scale: Double, speed: Double, phase: Double)] = [
        (0.08, 1.0, 9, 0.0),
        (0.22, 0.7, 6, 0.45),
        (0.55, 1.2, 4, 0.2),
        (0.80, 0.8, 7, 0.7),
    ]

    var body: some View {
        Canvas { context, size in
            context.opacity = 0.55
            context.addFilter(.blur(radius: 6))

            for cloud in clouds {
                let travel = size.width + 300
                let x = (cloud.phase * travel + time * cloud.speed)
                    .truncatingRemainder(dividingBy: travel) - 150
                let center = CGPoint(x: x, y: size.height * cloud.y)
                context.fill(cloudPath(at: center, scale: cloud.scale), with: .color(.white))
            }
        }
        .allowsHitTesting(false)
    }

    /// A cloud is just three overlapping ellipses.
    private func cloudPath(at c: CGPoint, scale s: Double) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: c.x - 70 * s, y: c.y - 18 * s, width: 140 * s, height: 44 * s))
        path.addEllipse(in: CGRect(x: c.x - 40 * s, y: c.y - 42 * s, width: 70 * s, height: 60 * s))
        path.addEllipse(in: CGRect(x: c.x, y: c.y - 32 * s, width: 60 * s, height: 46 * s))
        return path
    }
}

// MARK: - Stars (dark mode)

private struct StarField: View {
    let time: Double

    /// Fixed pseudo-random star positions, so stars don't jump around on every rebuild.
    private static let stars: [(x: Double, y: Double, size: Double, speed: Double)] = {
        var generator = SeededGenerator(seed: 42)
        return (0..<60).map { _ in
            (Double.random(in: 0...1, using: &generator),
             Double.random(in: 0...0.7, using: &generator),
             Double.random(in: 1...2.6, using: &generator),
             Double.random(in: 0.5...2, using: &generator))
        }
    }()

    var body: some View {
        Canvas { context, size in
            // A soft glow drifting across the top of the screen.
            let glowX = size.width * (0.5 + 0.3 * sin(time * 0.15))
            let glowRect = CGRect(x: glowX - 180, y: -120, width: 360, height: 360)
            context.fill(Path(ellipseIn: glowRect),
                         with: .radialGradient(Gradient(colors: [Color(hex: 0x7B5CFF, opacity: 0.35), .clear]),
                                               center: CGPoint(x: glowRect.midX, y: glowRect.midY),
                                               startRadius: 0,
                                               endRadius: 180))

            for star in Self.stars {
                // Each star twinkles at its own speed: opacity follows a sine wave.
                let twinkle = 0.35 + 0.65 * (0.5 + 0.5 * sin(time * star.speed + star.x * 10))
                let rect = CGRect(x: star.x * size.width,
                                  y: star.y * size.height,
                                  width: star.size,
                                  height: star.size)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(twinkle)))
            }
        }
        .allowsHitTesting(false)
    }
}

/// A tiny deterministic random number generator (SplitMix64).
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

#Preview("Pastel") {
    AnimatedBackground()
        .environment(\.theme, .pastel)
}

#Preview("Cinematic") {
    AnimatedBackground()
        .environment(\.theme, .cinematic)
}

//
//  StateViews.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

/// A friendly full-screen message with a gently floating icon,
/// used for empty, idle and error states.
struct AnimatedStateView: View {

    @Environment(\.theme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(theme.accentGradient)
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .opacity(0.45)

                Image(systemName: systemImage)
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(theme.accentGradient)
            }
            // Flutter: `PhaseAnimator` cycles through a list of phases forever, animating
            // between each one. It's a looping `TweenSequence` with no controller to manage.
            .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, isUp in
                content
                    .offset(y: isUp ? -10 : 6)
                    .rotationEffect(.degrees(isUp ? 4 : -4))
            } animation: { _ in
                .easeInOut(duration: 1.8)
            }

            Text(title)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(theme.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let actionTitle, let action {
                Button(action: action) {
                    PillButtonLabel(title: actionTitle, systemImage: "arrow.clockwise")
                }
                .buttonStyle(.pressable)
                .padding(.top, 6)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Bold rounded section title used across screens.
struct SectionHeader: View {
    @Environment(\.theme) private var theme
    let title: String

    var body: some View {
        Text(title)
            .font(.system(.title3, design: .rounded, weight: .bold))
            .foregroundStyle(theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Placeholder grid shown while films load.
struct SkeletonGrid: View {
    var showsHero = false

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if showsHero {
                    SkeletonBlock(cornerRadius: 26)
                        .frame(height: 210)
                }
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(0..<6, id: \.self) { _ in
                        SkeletonBlock(cornerRadius: 22)
                            .aspectRatio(2 / 3, contentMode: .fit)
                    }
                }
            }
            .padding()
        }
        .scrollDisabled(true)
    }
}

#Preview("State view") {
    AnimatedStateView(systemImage: "cloud.sun.rain",
                      title: "Something went wrong",
                      message: "The spirits couldn't reach the server.",
                      actionTitle: "Try again") {}
}

#Preview("Skeleton") {
    SkeletonGrid(showsHero: true)
}

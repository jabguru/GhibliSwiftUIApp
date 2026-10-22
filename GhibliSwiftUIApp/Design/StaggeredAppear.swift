//
//  StaggeredAppear.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

// Flutter: `flutter_staggered_animations`. Each item starts hidden and animates in
// once it appears, delayed by its index, so a grid "cascades" into place.
struct StaggeredAppear: ViewModifier {

    let index: Int
    var baseDelay: Double = 0.06

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible || reduceMotion ? 0 : 30)
            .scaleEffect(isVisible || reduceMotion ? 1 : 0.92)
            .onAppear {
                // Cap the delay so items far down a lazy grid don't wait forever.
                let delay = Double(min(index, 8)) * baseDelay
                withAnimation(.spring(response: 0.55, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggeredAppear(index: Int) -> some View {
        modifier(StaggeredAppear(index: index))
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(0..<6) { index in
            RoundedRectangle(cornerRadius: 16)
                .fill(.teal.gradient)
                .frame(height: 60)
                .staggeredAppear(index: index)
        }
    }
    .padding()
}

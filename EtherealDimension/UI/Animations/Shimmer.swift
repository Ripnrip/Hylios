//
//  Shimmer.swift
//  Hylios
//

import SwiftUI

/// 🎭 **Shimmer** — *The Liquid Light* ✨
///
/// A moving highlight that sweeps across any view — ported (adapted) from
/// open-swiftui-animations by @amosgyamfi. Use on text or placeholders that
/// await a result. Honors Reduce Motion: collapses to a steady opacity.
struct Shimmer: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1.2

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.overlay {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.75), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
                .offset(x: phase * 220)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1.2
                    }
                }
            }
        }
    }
}

extension View {
    /// ✨ Apply the shimmering highlight.
    func shimmering() -> some View { modifier(Shimmer()) }
}

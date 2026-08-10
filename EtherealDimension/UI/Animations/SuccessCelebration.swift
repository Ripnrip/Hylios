//
//  SuccessCelebration.swift
//  Hylios
//

import SwiftUI

/// 🎭 **SuccessCelebration** — *The Radiant Bloom* 🌟
///
/// Three expanding rings blooming outward from the seal — the hush of success
/// made visible. Ported (adapted) from open-swiftui-animations by @amosgyamfi.
/// Honors Reduce Motion: collapses to nothing (the seal speaks for itself).
struct SuccessCelebration: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    var body: some View {
        ZStack {
            if !reduceMotion {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(.green.opacity(0.55), lineWidth: 2)
                        .frame(width: 64, height: 64)
                        .scaleEffect(animate ? 3.2 : 1)
                        .opacity(animate ? 0 : 0.85)
                        .animation(
                            .easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(Double(i) * 0.45),
                            value: animate
                        )
                }
            }
        }
        .onAppear { animate = true }
        .allowsHitTesting(false)
    }
}

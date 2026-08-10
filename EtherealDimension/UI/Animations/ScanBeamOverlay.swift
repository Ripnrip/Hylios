//
//  ScanBeamOverlay.swift
//  Hylios
//

import SwiftUI

/// 🎭 **ScanBeamOverlay** — *The Sweeping Gaze* 🔵
///
/// A luminous vertical beam that sweeps across the live capture — the signature
/// Hylios scan motif (ported, with adaptation, from open-swiftui-animations by
/// @amosgyamfi). Sits over the RoomCaptureView and never blocks its touches.
/// Honors Reduce Motion: collapses to a calm, static center glow.
struct ScanBeamOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var x: CGFloat = -0.6

    var body: some View {
        GeometryReader { geo in
            if reduceMotion {
                beam(width: geo.size.width * 0.5)
                    .opacity(0.45)
                    .frame(maxWidth: .infinity)
            } else {
                beam(width: geo.size.width * 0.16)
                    .offset(x: x * geo.size.width)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                            x = 0.6
                        }
                    }
            }
        }
        .allowsHitTesting(false)
    }

    /// 🔵 The beam itself — a vertical streak of liquid light.
    private func beam(width: CGFloat) -> some View {
        LinearGradient(
            colors: [.clear, .cyan.opacity(0.5), .white.opacity(0.85), .cyan.opacity(0.5), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: width)
        .blur(radius: 6)
        .blendMode(.plusLighter)
    }
}

//
//  MeshBackground.swift
//  Hylios
//

import SwiftUI

/// 🎭 **MeshBackground** — *The Ethereal Backdrop* 🌌
///
/// A living mesh of violet, indigo, and cyan — the signature sky of the
/// Magical Dimension. Built on iOS 18 `MeshGradient`; this is the floor
/// that grants us the spell. (Liquid Glass embellishments land on iOS 26.)
struct MeshBackground: View {
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1],
            ],
            colors: [
                Color(red: 0.05, green: 0.03, blue: 0.12),
                Color(red: 0.24, green: 0.10, blue: 0.45),
                Color(red: 0.04, green: 0.05, blue: 0.12),
                Color(red: 0.20, green: 0.08, blue: 0.40),
                Color(red: 0.45, green: 0.28, blue: 0.70),
                Color(red: 0.08, green: 0.30, blue: 0.42),
                Color(red: 0.04, green: 0.05, blue: 0.12),
                Color(red: 0.10, green: 0.30, blue: 0.45),
                Color(red: 0.05, green: 0.03, blue: 0.12),
            ]
        )
        .ignoresSafeArea()
    }
}

#Preview {
    MeshBackground()
}

//
//  ObjectScanView.swift
//  Hylios
//

import SwiftUI

/// 🎭 **ObjectScanView** — *The Orbital Rite* 🧊 (scaffold)
///
/// Object Capture (photogrammetry) — orbit a single object and Hylios will weave it
/// into a detailed 3D mesh. This is the entry scaffold: the guided-orbit capture flow
/// (AR image gathering → `PhotogrammetrySession` → USDZ) lands in the next increment
/// (tracked separately). For now it sets the stage and the intent.
struct ObjectScanView: View {
    let onExit: () -> Void

    var body: some View {
        ZStack {
            MeshBackground()
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "cube.transparent.fill")
                    .font(.system(size: 72, weight: .ultraLight))
                    .symbolEffect(.pulse, options: .repeating)
                    .foregroundStyle(.white.opacity(0.85))
                Text("Object Capture")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                Text("Orbit an object and Hylios will weave it into a detailed 3D mesh.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Label("Guided orbit capture arrives next", systemImage: "wand.and.stars")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                Spacer()
                Button(action: onExit) {
                    Label("Back to modes", systemImage: "chevron.left")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.bottom, 48)
            }
        }
    }
}

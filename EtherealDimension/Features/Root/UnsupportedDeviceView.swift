//
//  UnsupportedDeviceView.swift
//  Hylios
//

import SwiftUI

/// 🎭 **UnsupportedDeviceView** — *The Gentle Turn-Away* 🌙
///
/// "Not every lens can see the unseen." Whispers to the seeker that their
/// device lacks the LiDAR scanner Hylios needs — with grace, never a crash.
struct UnsupportedDeviceView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "sensor.tag.radiowaves.forward")
                .font(.system(size: 64, weight: .light))
                .symbolEffect(.pulse, options: .repeating)
                .foregroundStyle(.tertiary)

            Text("LiDAR required")
                .font(.title2.weight(.semibold))

            Text("Hylios needs an iPhone Pro or iPad Pro with a LiDAR scanner to capture your space.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { MeshBackground() }
    }
}

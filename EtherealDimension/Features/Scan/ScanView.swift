//
//  ScanView.swift
//  Hylios
//

import SwiftUI

/// 🎭 **ScanView** — *The Scrying Stage* 🔮 (Phase 3 placeholder)
///
/// For now, a branded landing that hums with potential. Phase 4 will awaken the
/// real `RoomCaptureView` here — turning the living world into precise geometry.
/// The skeleton is dressed; the soul arrives next.
struct ScanView: View {
    var body: some View {
        ZStack {
            MeshBackground()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "viewfinder.rectangular")
                    .font(.system(size: 72, weight: .ultraLight))
                    .symbolEffect(.pulse, options: .repeating)
                    .foregroundStyle(.white.opacity(0.85))

                Text("Hylios")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Text("Magical Space Intelligence")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))

                Text("The RoomPlan scan awakens in Phase 4.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))

                Spacer()

                Label("RoomPlan ready on this device", systemImage: "checkmark.seal.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    ScanView()
}

//
//  ScanHub.swift
//  Hylios
//

import SwiftUI

/// 🎭 **ScanHub** — *The Crossroads* 🧭
///
/// The chooser between Hylios's two lenses: a Room scan (RoomPlan) or an Object
/// scan (Object Capture). Selecting a mode presents its flow full-screen; the close
/// control returns here. Replaces the old "straight into the room scan" entry.
struct ScanHub: View {
    @State private var mode: ScanMode?

    var body: some View {
        ZStack {
            MeshBackground()
            if let mode {
                Group {
                    switch mode {
                    case .room: RoomScanView(onExit: { self.mode = nil })
                    case .object: ObjectScanView(onExit: { self.mode = nil })
                    }
                }
                .transition(.opacity)
            } else {
                ScanChooser(onSelect: { mode = $0 })
            }
        }
        .animation(.snappy, value: mode)
    }
}

/// 🌟 The chooser — two cards, one decision.
private struct ScanChooser: View {
    let onSelect: (ScanMode) -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "viewfinder.rectangular")
                .font(.system(size: 60, weight: .ultraLight))
                .symbolEffect(.pulse, options: .repeating)
                .foregroundStyle(.white.opacity(0.85))
            Text("Hylios")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
            Text("Magical Space Intelligence")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))

            VStack(spacing: 16) {
                ForEach(ScanMode.allCases, id: \.self) { mode in
                    Button { onSelect(mode) } label: {
                        HStack(spacing: 14) {
                            Image(systemName: mode.symbol)
                                .font(.title2)
                                .frame(width: 30)
                                .foregroundStyle(.cyan)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.title).font(.headline)
                                Text(mode.subtitle).font(.caption).foregroundStyle(.white.opacity(0.7))
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .foregroundStyle(.white)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    ScanHub()
}

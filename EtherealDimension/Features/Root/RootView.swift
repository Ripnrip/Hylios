//
//  RootView.swift
//  Hylios
//

import RoomPlan
import SwiftUI

/// 🎭 **RootView** — *The Grand Foyer* 🪄
///
/// The first room every seeker enters. It reads the device's aura:
/// those graced with a LiDAR scanner proceed to the scan; the rest are
/// gently guided to the `UnsupportedDeviceView` — no harsh errors, only kindness.
struct RootView: View {
    var body: some View {
        Group {
            if RoomCaptureSession.isSupported {
                ScanView() // 🔮 Phase 4 awakens the real RoomCaptureView here.
            } else {
                UnsupportedDeviceView()
            }
        }
    }
}

// 🎬 Xcode preview — the foyer, lit two ways.
#Preview("Supported") {
    RootView()
}

#Preview("Unsupported", traits: .sizeThatFitsLayout) {
    UnsupportedDeviceView()
}

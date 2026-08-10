//
//  HyliosClipApp.swift
//  HyliosClip (App Clip)
//

import SwiftUI

/// 🎭 **HyliosClipApp** — *The Threshold* 🚪
///
/// The App Clip entry: a featherweight doorway into a single scan — try Hylios
/// instantly from a link or QR code, no install required. It reuses the full app's
/// `RootView`, so the experience is one and the same, merely briefer. The full app
/// is offered on the App Clip card (configured in App Store Connect) for those who
/// want exports, history, and the rest.
@main
struct HyliosClipApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

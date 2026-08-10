//
//  ScanActivityAttributes.swift
//  Hylios (shared with the ScanActivity widget extension)
//

import ActivityKit
import Foundation

/// 📡 **ScanActivityAttributes** — the shape of a live scan, surfaced to the
/// Lock Screen and Dynamic Island. Shared between the app and the widget extension
/// (compiled into both targets) so both sides speak the same language.
struct ScanActivityAttributes: ActivityAttributes {
    /// The mutable, moment-to-moment state of an in-flight scan.
    public struct ContentState: Codable, Hashable {
        var phaseLabel: String   // "Scanning" · "Crystallizing…" · "Saved" · "Failed"
        var progress: Double      // 0…1 (a hint of how far along the ritual is)
    }

    /// The stable identity of the scan — what doesn't change while it runs.
    var spaceName: String
}

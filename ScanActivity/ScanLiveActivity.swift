//
//  ScanLiveActivity.swift
//  Hylios ScanActivity (widget extension)
//

import ActivityKit
import WidgetKit
import SwiftUI

/// 🎭 **HyliosScanWidgetBundle** — the extension's entry point.
@main
struct HyliosScanWidgetBundle: WidgetBundle {
    var body: some Widget { ScanLiveActivity() }
}

/// 📡 **ScanLiveActivity** — the Live Activity itself: a Lock Screen card while a
/// scan runs, plus a Dynamic Island presence (compact + expanded).
struct ScanLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScanActivityAttributes.self) { context in
            // 🪟 Lock Screen presentation.
            HStack(spacing: 14) {
                Image(systemName: "viewfinder.rectangular")
                    .font(.title2)
                    .foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hylios · \(context.attributes.spaceName)")
                        .font(.headline)
                    Text(context.state.phaseLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(16)
            .activityBackgroundTint(.black.opacity(0.45))
            .activitySystemActionForegroundColor(.cyan)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "viewfinder.rectangular")
                        .foregroundStyle(.cyan)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.phaseLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.cyan)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Hylios · \(context.attributes.spaceName)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "viewfinder.rectangular")
            } compactTrailing: {
                Text(context.state.phaseLabel)
                    .font(.caption2)
            } minimal: {
                Image(systemName: "viewfinder.rectangular")
            }
        }
    }
}

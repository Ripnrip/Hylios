//
//  RoomCaptureViewRepresentable.swift
//  Hylios
//

import RoomPlan
import SwiftUI

/// 🎭 **RoomCaptureViewRepresentable** — *The Bridge Between Worlds* 🌉
///
/// SwiftUI cannot speak directly to RoomPlan's UIView, so this `UIViewRepresentable`
/// translates: it conjures a `RoomCaptureView`, binds its session to a `RoomCaptureDelegate`
/// (the Objc delegate), and hands the lens to the `ScanModel`.
struct RoomCaptureViewRepresentable: UIViewRepresentable {
    @Bindable var model: ScanModel

    /// The RoomPlan delegate lives as a top-level NSObject (a stable Objc name + NSCoding,
    /// which RoomPlan's delegate lineage requires). SwiftUI retains it for us.
    func makeCoordinator() -> RoomCaptureDelegate { RoomCaptureDelegate(model: model) }

    func makeUIView(context: Context) -> RoomCaptureView {
        let view = RoomCaptureView()
        view.captureSession.delegate = context.coordinator
        view.delegate = context.coordinator
        model.attach(view) // 🌅 awaken the session
        return view
    }

    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
        // 🎬 The session drives itself — nothing to update here.
    }
}

/// 🌉 **RoomCaptureDelegate** — the RoomPlan delegate bridge.
///
/// A top-level `NSObject` (RoomPlan's protocols descend from `NSObjectProtocol` and
/// require `NSCoding`; top-level keeps the Objc archive name stable). It receives
/// capture callbacks and forwards them to the `@Observable` `ScanModel`. The methods
/// are `nonisolated` (RoomPlan calls them) and hop back onto the MainActor.
final class RoomCaptureDelegate: NSObject, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {
    weak var model: ScanModel?

    init(model: ScanModel) {
        self.model = model
        super.init()
    }

    // MARK: NSCoding (RoomPlan's lineage requires it; archival is unsupported) 📦
    init?(coder: NSCoder) { nil }
    func encode(with coder: NSCoder) {}

    // MARK: RoomPlan delegates 🪄
    nonisolated func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        true
    }

    nonisolated func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        // RoomPlan dispatches UI delegates on the main thread — re-enter our isolation.
        // Capture the Sendable model ref (not self) so the MainActor closure doesn't race.
        let model = self.model
        MainActor.assumeIsolated {
            model?.handleCaptureResult(processedResult, error: error)
        }
    }
}

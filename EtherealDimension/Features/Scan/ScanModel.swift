//
//  ScanModel.swift
//  Hylios
//

import Foundation
import OSLog
import RoomPlan
import UIKit

/// 🎭 **ScanModel** — *The Alchemist's Ledger* 🔮
///
/// The beating heart of the scan: an `@Observable` state machine that conjures
/// geometry out of thin air.  `idle → scanning → processing → done` (or `failed`).
/// Owns the `RoomCaptureSession`, the final `CapturedRoom`, and the exported USDZ.
///
/// Pure model — the Objc RoomPlan delegates live in `RoomCaptureViewRepresentable.Coordinator`,
/// which keeps `@Observable` out of the `@objc` protocol weeds.
@MainActor
@Observable
final class ScanModel {

    /// 🌟 The phase of the ritual.
    enum Phase: Equatable {
        case idle
        case scanning
        case processing
        case done
        case failed(String)
    }

    /// ✨ Current phase — the view reacts to this single source of truth.
    var phase: Phase = .idle

    /// 🧊 The exported USDZ, ready to share with the world.
    var exportedFileURL: URL?

    /// 📏 The crystal's weight (bytes) — a touch of mortal detail.
    var exportedFileSize: Int64 = 0

    /// 🔮 The lens itself, and the session that drives it.
    private var captureView: RoomCaptureView?
    private let sessionConfig = RoomCaptureSession.Configuration()
    private var capturedRoom: CapturedRoom?

    // MARK: - The ritual 🪄

    /// 🌅 Bind the lens and awaken the session. (Delegates are wired by the Representable.)
    func attach(_ view: RoomCaptureView) {
        captureView = view
        phase = .scanning
        view.captureSession.run(configuration: sessionConfig)
        Haptic.medium.play()
        Logger.scan.info("🌙 Scan awakens.")
    }

    /// 🌇 The seeker cries "Done!" — stop the lens and begin the alchemy of processing.
    func finishScan() {
        guard phase == .scanning else { return }
        phase = .processing
        captureView?.captureSession.stop()
        Haptic.light.play()
        Logger.scan.info("🌙 Scan stopped; weaving the model…")
    }

    /// 🔁 Reset the stage for another room.
    func reset() {
        phase = .idle
        capturedRoom = nil
        exportedFileURL = nil
        exportedFileSize = 0
    }

    /// 📨 The Coordinator calls this when RoomPlan finishes.
    func handleCaptureResult(_ room: CapturedRoom, error: Error?) {
        if let error {
            Logger.scan.error("💥 RoomPlan error: \(error.localizedDescription)")
            phase = .failed(error.localizedDescription)
            Haptic.error.play()
            return
        }
        export(room)
    }

    // MARK: - Crystallization 🧊

    /// Export the captured room into a shareable USDZ (parametric form).
    private func export(_ room: CapturedRoom) {
        let dir = FileManager.default.temporaryDirectory
            .appending(path: "HyliosExports", directoryHint: .isDirectory)
        let url = dir.appending(path: "Hylios-Room.usdz")
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try? FileManager.default.removeItem(at: url) // clear the previous crystal
            try room.export(to: url, exportOptions: .parametric)
            let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
            capturedRoom = room
            exportedFileURL = url
            exportedFileSize = size
            phase = .done
            Haptic.success.play()
            Logger.scan.info("💎 Crystallized USDZ (\(size) bytes) → \(url.path)")
        } catch {
            Logger.scan.error("💥 Export failed: \(error.localizedDescription)")
            phase = .failed(error.localizedDescription)
            Haptic.error.play()
        }
    }
}

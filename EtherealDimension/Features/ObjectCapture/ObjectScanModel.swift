//
//  ObjectScanModel.swift
//  Hylios
//

import Foundation
import OSLog
import RealityKit
import SwiftUI
import UIKit

/// 🎭 **ObjectScanModel** — *The Orbital Alchemist* 🧊
///
/// Drives an Object Capture (photogrammetry) session: the iOS 18 async
/// `ObjectCaptureSession` gathers images of an object as the seeker orbits it,
/// then a `PhotogrammetrySession` weaves those images into a detailed USDZ mesh.
/// State machine: idle → detecting → capturing → finishing → reconstructing → done/failed.
@MainActor
@Observable
final class ObjectScanModel {

    /// 🌟 The phase of the orbital rite.
    enum Phase: Equatable {
        case idle
        case detecting
        case capturing
        case finishing
        case reconstructing(Double)
        case done
        case failed(String)
    }

    var phase: Phase = .idle
    var exportedURL: URL?

    /// 🔮 The capture session, held for `ObjectCaptureView`.
    var session: ObjectCaptureSession?

    private var imagesFolder: URL?
    private var photoSession: PhotogrammetrySession?

    // MARK: - Capture 🪄

    /// 🌅 Conjure the session and begin. Called on appear.
    func beginCapture() async {
        let folder = Self.makeImagesFolder()
        imagesFolder = folder
        let s = await ObjectCaptureSession()
        session = s
        var config = ObjectCaptureSession.Configuration()
        config.isOverCaptureEnabled = true
        await s.start(imagesDirectory: folder, configuration: config)
        phase = .detecting
        Haptic.medium.play()
        Logger.scan.info("🧊 Object capture started → \(folder.path)")

        // Observe session state + scan-pass completion to drive the flow.
        Task { @MainActor [weak self] in
            for await state in s.stateUpdates {
                guard let self else { return }
                Logger.scan.info("🧊 ObjectCapture state: \(String(describing: state))")
                switch state {
                case .ready: self.session?.startDetecting()
                case .detecting: self.phase = .detecting
                case .capturing: self.phase = .capturing
                case .completed: Task { await self.reconstruct() }
                case .failed: self.phase = .failed("Object capture failed.")
                @unknown default: break
                }
            }
        }
        Task { @MainActor [weak self] in
            for await completed in s.userCompletedScanPassUpdates where completed {
                self?.phase = .finishing
            }
        }
    }

    /// The bounding box is set — begin orbiting + capturing.
    func userStartCapturing() { session?.startCapturing() }

    /// The seeker finished orbiting — finalize, then weave the mesh.
    func userFinish() {
        session?.finish()
        phase = .finishing
    }

    /// Abandon the rite.
    func cancel() {
        session?.cancel()
        phase = .idle
    }

    // MARK: - Reconstruction 🧬

    private func reconstruct() async {
        guard let folder = imagesFolder else { return }
        let out = FileManager.default.temporaryDirectory
            .appending(path: "HyliosExports", directoryHint: .isDirectory)
            .appending(path: "Hylios-Object.usdz")
        do {
            try FileManager.default.createDirectory(at: out.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? FileManager.default.removeItem(at: out)
            let ps = try PhotogrammetrySession(input: folder)
            photoSession = ps
            phase = .reconstructing(0)
            try ps.process(requests: [.modelFile(url: out)])
            for try await output in ps.outputs {
                switch output {
                case .requestProgress(_, let fraction):
                    self.phase = .reconstructing(Double(fraction))
                case .requestComplete(_, let result):
                    if case .modelFile(let url) = result { self.exportedURL = url }
                case .processingComplete:
                    if self.exportedURL == nil { self.exportedURL = out }
                    self.phase = .done
                    Haptic.success.play()
                    Logger.scan.info("💎 Object USDZ → \(self.exportedURL?.path ?? "?")")
                    return
                case .requestError(_, let err):
                    Logger.scan.error("💥 Reconstruction error: \(err.localizedDescription)")
                    self.phase = .failed(err.localizedDescription)
                    Haptic.error.play()
                    return
                default: break
                }
            }
        } catch {
            Logger.scan.error("💥 Reconstruction failed: \(error.localizedDescription)")
            phase = .failed(error.localizedDescription)
            Haptic.error.play()
        }
    }

    /// 🔁 Reset for another object.
    func reset() {
        phase = .idle
        exportedURL = nil
        session = nil
        photoSession = nil
        imagesFolder = nil
    }

    /// 📁 A fresh per-scan images folder.
    private static func makeImagesFolder() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appending(path: "HyliosObjectImages", directoryHint: .isDirectory)
        try? FileManager.default.removeItem(at: dir)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}

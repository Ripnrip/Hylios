//
//  ObjectScanView.swift
//  Hylios
//

import RealityKit
import SwiftUI

/// 🎭 **ObjectScanView** — *The Orbital Rite* 🧊
///
/// Object Capture (photogrammetry). `ObjectCaptureView` guides the seeker through
/// detecting → capturing (orbit the object) → finishing, then `ObjectScanModel`
/// reconstructs the images into a USDZ mesh and offers a ShareLink.
struct ObjectScanView: View {
    let onExit: () -> Void
    @State private var model = ObjectScanModel()

    var body: some View {
        ZStack {
            MeshBackground()
            content
                .animation(.snappy, value: model.phase)
        }
        .task { if model.phase == .idle { await model.beginCapture() } }
        .overlay(alignment: .topLeading) {
            if model.phase == .idle || model.phase == .detecting {
                Button(action: onExit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2).foregroundStyle(.white.opacity(0.7)).padding()
                }
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .idle, .detecting, .capturing, .finishing:
            captureStage
        case .reconstructing(let fraction):
            reconstructStage(fraction: fraction)
        case .done:
            if let url = model.exportedURL { doneStage(url: url) }
        case .failed(let message):
            failedStage(message: message)
        }
    }

    // MARK: Stages 🌗

    private var captureStage: some View {
        ZStack {
            if let session = model.session {
                ObjectCaptureView(session: session).ignoresSafeArea()
            }
            VStack {
                Spacer()
                switch model.phase {
                case .detecting:
                    stageButton("Start Capturing", system: "play.fill") { model.userStartCapturing() }
                case .capturing:
                    stageButton("Finish", system: "checkmark.circle.fill") { model.userFinish() }
                case .finishing:
                    Label("Finalizing…", systemImage: "hourglass")
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundStyle(.white)
                default:
                    EmptyView()
                }
            }
            .padding(.bottom, 40)
        }
    }

    private func reconstructStage(fraction: Double) -> some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView(value: fraction).tint(.white).frame(width: 200)
            Text("Weaving the mesh…").font(.headline).foregroundStyle(.white)
            Text("\(Int(fraction * 100))%").font(.caption).foregroundStyle(.white.opacity(0.7))
            Spacer()
        }
    }

    private func doneStage(url: URL) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "cube.transparent.fill").font(.system(size: 60)).foregroundStyle(.green)
                .overlay(SuccessCelebration())
            Text("Object captured").font(.title.weight(.bold)).foregroundStyle(.white)
            ShareLink(item: url, preview: SharePreview("Hylios Object Scan")) {
                Label("Share USDZ", systemImage: "square.and.arrow.up")
                    .font(.headline).frame(maxWidth: .infinity).padding()
            }
            .buttonStyle(.borderedProminent)
            Button(action: onExit) {
                Label("Back to modes", systemImage: "chevron.left")
                    .font(.subheadline.weight(.medium)).foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private func failedStage(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("The spell faltered").font(.title2.weight(.semibold)).foregroundStyle(.white)
            Text(message).font(.caption).foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center).padding(.horizontal)
            Button("Back to modes", action: onExit).buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(.horizontal)
    }

    private func stageButton(_ title: String, system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: system).font(.headline).frame(maxWidth: .infinity).padding()
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
    }
}

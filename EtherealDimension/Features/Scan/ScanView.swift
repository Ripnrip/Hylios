//
//  ScanView.swift
//  Hylios
//

import SwiftUI

/// 🎭 **ScanView** — *The Scrying Stage* 🔮
///
/// The room where the scan happens. It reacts to `ScanModel.phase`:
/// idle invites, scanning shows the live lens + a Finish button, processing
/// shows the alchemy, done reveals the crystallized USDZ to share.
struct RoomScanView: View {
    @State private var model = ScanModel()
    var onExit: () -> Void = {}

    var body: some View {
        ZStack {
            MeshBackground()
            content
                .animation(.snappy, value: model.phase)
        }
        .overlay(alignment: .topLeading) {
            if model.phase == .idle {
                Button(action: onExit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding()
                }
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .idle:
            ScanIdleView { model.phase = .scanning }
        case .scanning:
            ScanLiveView(model: model)
        case .processing:
            ScanProcessingView()
        case .done:
            if let url = model.exportedFileURL {
                ScanDoneView(fileURL: url, sizeBytes: model.exportedFileSize, onRescan: model.reset)
            }
        case .failed(let message):
            ScanFailedView(message: message, onRetry: model.reset)
        }
    }
}

// MARK: - Phases 🌗

/// 🌙 idle — the invitation.
private struct ScanIdleView: View {
    let onStart: () -> Void
    var body: some View {
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
            Spacer()
            Button(action: onStart) {
                Label("Begin Scan", systemImage: "wand.and.stars")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 48)
        }
    }
}

/// 🌌 scanning — the live lens + the seeker's Finish control.
private struct ScanLiveView: View {
    @Bindable var model: ScanModel
    var body: some View {
        RoomCaptureViewRepresentable(model: model)
            .ignoresSafeArea()
            .overlay(ScanBeamOverlay()) // 🔵 the sweeping gaze over the live lens
        VStack {
            Spacer()
            Text("Move slowly around the room")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.bottom, 16)
            Button {
                model.finishScan()
            } label: {
                Label("Finish", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

/// 🌀 processing — the alchemy in motion.
private struct ScanProcessingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .tint(.white)
            Text("Crystallizing your space…")
                .font(.headline)
                .foregroundStyle(.white)
                .shimmering() // ✨ liquid light while the geometry weaves
            Text("Hylios is weaving the geometry.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

/// 💎 done — the crystal, ready to share.
private struct ScanDoneView: View {
    let fileURL: URL
    let sizeBytes: Int64
    let onRescan: () -> Void
    @State private var animateSeal = false
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .overlay(SuccessCelebration()) // 🌟 the radiant bloom
                .scaleEffect(animateSeal ? 1.0 : 0.4)
                .animation(.bouncy, value: animateSeal)
                .onAppear { animateSeal = true }
            Text("Scan complete")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
            Text(sizeBytes.formatted(.byteCount(style: .file)))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            ShareLink(item: fileURL, preview: SharePreview("Hylios Room Scan")) {
                Label("Share USDZ", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            Button(action: onRescan) {
                Label("Scan another room", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

/// 🌩️ failed — the spell faltered; offer a retry.
private struct ScanFailedView: View {
    let message: String
    let onRetry: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
            Text("The spell faltered")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
            Text(message)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try again", action: onRetry)
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    RoomScanView(onExit: {})
}

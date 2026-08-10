//
//  Haptics.swift
//  Hylios
//

import UIKit

/// 🎭 **Haptic** — *The Whisper of Touch* ✨
///
/// Fires gentle physical cues on **meaningful transitions** — never on loops,
/// never on polls. Respects Reduce Motion: motion-disabled seekers feel nothing
/// (by design — accessibility first, theatre second). (Canon: motion-haptics.md)
@MainActor
enum Haptic {
    case selection, light, medium, success, warning, error

    /// 🌟 Speak the cue — unless the seeker has asked for stillness.
    func play() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        switch self {
        case .selection: UISelectionFeedbackGenerator().selectionChanged()
        case .light:     UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .success:   UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:   UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:     UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

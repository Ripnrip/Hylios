//
//  ScanMode.swift
//  Hylios
//

import Foundation

/// 🎭 **ScanMode** — *Two Lenses, One Dimension* 🔭
///
/// Hylios offers two kinds of capture:
/// - `.room`   — RoomPlan: walls, floors, openings → a parametric model of a whole space.
/// - `.object` — Object Capture: orbit a single thing → a detailed photogrammetric mesh.
enum ScanMode: String, CaseIterable, Sendable {
    case room, object

    var title: String {
        switch self {
        case .room: "Scan a Room"
        case .object: "Scan an Object"
        }
    }

    var subtitle: String {
        switch self {
        case .room: "Walls, floors, layout — a whole space."
        case .object: "Orbit one thing into a detailed 3D mesh."
        }
    }

    var symbol: String {
        switch self {
        case .room: "house.fill"
        case .object: "cube.transparent.fill"
        }
    }
}

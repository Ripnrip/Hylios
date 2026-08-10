//
//  SpaceTypes.swift
//  Hylios
//

import Foundation

// 🏷️ The taxonomy of spaces Hylios can capture.
// Cleansed from the old stringly-typed picker — farewell, "appartment" typo. 👋
// (Canon: enums over strings, CaseIterable, Sendable, exhaustive switches.)

/// The top-level category of a space.
enum SpaceCategory: String, CaseIterable, Sendable {
    case residential, commercial, `public`
}

/// Residential spaces — where life unfolds.
enum ResidentialSpace: String, CaseIterable, Sendable {
    case apartment
    case bedroom
    case livingRoom = "living room"
    case bathroom
    case kitchen
    case garage
    case outside
    case other
}

/// Commercial spaces — where commerce hums.
enum CommercialSpace: String, CaseIterable, Sendable {
    case office, restaurant, cafe, bar, gym, other
}

/// Public spaces — shared by all.
enum PublicSpace: String, CaseIterable, Sendable {
    case park, library, monument, school, metro, other
}

extension SpaceCategory {
    /// 🌟 The display names of the sub-spaces belonging to this category.
    /// Used by the Phase-4 picker. Switch is exhaustive by design.
    var subSpaces: [String] {
        switch self {
        case .residential: ResidentialSpace.allCases.map(\.rawValue)
        case .commercial:  CommercialSpace.allCases.map(\.rawValue)
        case .public:      PublicSpace.allCases.map(\.rawValue)
        }
    }
}

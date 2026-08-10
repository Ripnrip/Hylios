//
//  Logger.swift
//  Hylios
//

import OSLog

/// 🔮 **Logger** — *The App's Structured Voice* 📜
///
/// One `os.Logger` per concern, namespaced under the app's subsystem.
/// Structured and intentional — never prose sludge, never secrets.
/// (Canon: logging.md.)
extension Logger {
    /// 🌌 The top-level Hylios subsystem.
    static let hylios = Logger(subsystem: "com.binarybros.EtherealDimension", category: "hylios")
    /// 🔮 The scan pipeline category.
    static let scan = Logger(subsystem: "com.binarybros.EtherealDimension", category: "scan")
}

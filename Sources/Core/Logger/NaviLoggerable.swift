//
//  NaviLogger.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 29/06/2026.
//

/// A logging interface used by Navi to report navigation events and failures.
public protocol NaviLoggerable {
    /// Logs an informational message.
    ///
    /// - Parameter message: The message to record.
    func logInfo(_ message: String)

    /// Logs an error or fault message.
    ///
    /// - Parameter message: The message to record.
    func logError(_ message: String)
}

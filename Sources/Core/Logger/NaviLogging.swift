//
//  NaviLogging.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 29/06/2026.
//
 
/// A logging interface used by Navi to report navigation events and failures.
public protocol NaviLogging {
    /// Logs an informational message.
    ///
    /// - Parameter message: The message to record.
    @available(*, deprecated, message: "Use logInfo(_: NaviLoggingInfoModel) instead. Will be removed in the next release.")
    func logInfo(_ message: String)

    /// Logs an error or fault message.
    ///
    /// - Parameter message: The message to record.
    @available(*, deprecated, message: "Use logError(_: NaviLoggingInfoModel) instead. Will be removed in the next release.")
    func logError(_ message: String)
    
    func logInfo(_ info: NaviLoggingInfoModel)
    func logError(_ info: NaviLoggingInfoModel)
}

public extension NaviLogging {
    func logInfo(_ info: NaviLoggingInfoModel) {
        logInfo(info.message)
    }

    func logError(_ info: NaviLoggingInfoModel) {
        logError(info.message)
    }
}

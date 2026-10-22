//
//  NavigationLogger.swift
//  Coordinators
//
//  Created by David Pall on 2026. 07. 13..
//

import Navi
import OSLog

final class NavigationLogger: NaviLogging {
    
    // MARK: - Private functions
    
    private let logger: Logger
    
    // MARK: - Lifecycle
    
    init() {
        logger = Logger(
            subsystem: "com.navi.example.coordinator",
            category: "Navi"
        )
    }
    
    // MARK: - Public functions
    
    func logInfo(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
    
    func logError(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }

    func logInfo(_ info: NaviLoggingInfoModel) {
        logger.info("\(info.message, privacy: .public) | pathCount: \(info.rawData.pathCount, privacy: .public)")
    }

    func logError(_ info: NaviLoggingInfoModel) {
        logger.error("\(info.message, privacy: .public) | pathCount: \(info.rawData.pathCount, privacy: .public)")
    }
}

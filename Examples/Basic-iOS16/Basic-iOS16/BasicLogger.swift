//
//  BasicLogger.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 13..
//

import Navi
import OSLog

final class BasicLogger: NaviLogging {
    let logger = Logger(subsystem: "com.navi.example.basic", category: "Navi")
    
    func logInfo(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
    
    func logError(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}

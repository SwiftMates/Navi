//
//  BasicExampleController.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import Foundation
import Navi
import OSLog

@Observable
final class BasicExampleController: NaviController {
    var properties = NaviControllerProperties(logger: BasicLogger())
}

final class BasicLogger: NaviLoggerable {
    let logger = Logger(subsystem: "com.navi.example.basic", category: "Navi")
    
    func logInfo(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
    
    func logError(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}

//
//  NaviCoordinatorProperties.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import SwiftUI
import OSLog

public struct NaviCoordinatorProperties {
    
    public var path: NavigationPath

    var naviStackOrigins: [NaviStackOriginKeys: Int]
    var naviLogger: Logger

    // MARK: - Lifecycle

    public init() {
        self.path = NavigationPath()
        self.naviStackOrigins = [:]
        self.naviLogger = Logger(subsystem: "Navi Package", category: "Navi")
    }
}

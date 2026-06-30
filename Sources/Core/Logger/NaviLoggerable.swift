//
//  NaviLogger.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 29/06/2026.
//

import Foundation

public protocol NaviLoggerable {
    func logInfo(_ message: String)
    func logError(_ message: String)
}

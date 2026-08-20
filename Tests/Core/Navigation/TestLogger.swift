//
//  TestLogger.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 06/07/2026.
//

@testable import Navi

final class TestLogger: NaviLoggerable {

    // MARK: - logInfo

    var logInfoCallsCount = 0
    var logInfoReceivedInvocations: [String] = []

    func logInfo(_ message: String) {
        logInfoCallsCount += 1
        logInfoReceivedInvocations.append(message)
    }

    // MARK: - logError

    var logErrorCallsCount = 0
    var logErrorCalled: Bool {
        logErrorCallsCount > 0
    }

    func logError(_ message: String) {
        logErrorCallsCount += 1
    }
}

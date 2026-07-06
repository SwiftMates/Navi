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
    var logInfoCalled: Bool {
        logInfoCallsCount > 0
    }

    var logInfoReceivedMessage: String?
    var logInfoReceivedInvocations: [String] = []
    var logInfoClosure: ((String) -> Void)?

    func logInfo(_ message: String) {
        logInfoCallsCount += 1
        logInfoReceivedMessage = message
        logInfoReceivedInvocations.append(message)
        logInfoClosure?(message)
    }

    // MARK: - logError

    var logErrorCallsCount = 0
    var logErrorCalled: Bool {
        logErrorCallsCount > 0
    }

    var logErrorReceivedMessage: String?
    var logErrorReceivedInvocations: [String] = []
    var logErrorClosure: ((String) -> Void)?

    func logError(_ message: String) {
        logErrorCallsCount += 1
        logErrorReceivedMessage = message
        logErrorReceivedInvocations.append(message)
        logErrorClosure?(message)
    }
}

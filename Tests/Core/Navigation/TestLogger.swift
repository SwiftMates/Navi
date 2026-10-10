//
//  TestLogger.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 06/07/2026.
//

@testable import Navi

final class TestLogger: NaviLogging {

    // MARK: - logInfo

    var logInfoCallsCount = 0
    var logInfoReceivedInvocations: [String] = []
    var logInfoReceivedInfoModels: [NaviLoggingInfoModel] = []

    func logInfo(_ message: String) {
        logInfoCallsCount += 1
        logInfoReceivedInvocations.append(message)
    }

    func logInfo(_ info: NaviLoggingInfoModel) {
        logInfoCallsCount += 1
        logInfoReceivedInvocations.append(info.message)
        logInfoReceivedInfoModels.append(info)
    }

    // MARK: - logError

    var logErrorCallsCount = 0
    var logErrorReceivedInvocations: [String] = []
    var logErrorReceivedInfoModels: [NaviLoggingInfoModel] = []
    var logErrorCalled: Bool {
        logErrorCallsCount > 0
    }

    func logError(_ message: String) {
        logErrorCallsCount += 1
        logErrorReceivedInvocations.append(message)
    }

    func logError(_ info: NaviLoggingInfoModel) {
        logErrorCallsCount += 1
        logErrorReceivedInvocations.append(info.message)
        logErrorReceivedInfoModels.append(info)
    }
}

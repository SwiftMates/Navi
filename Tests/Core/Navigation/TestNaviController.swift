//
//  TestNaviController.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 26/04/2026.
//

@testable import Navi

final class TestNaviController: NaviController {
    let logger = TestLogger()

    lazy var properties = NaviControllerProperties(logger: logger)
}

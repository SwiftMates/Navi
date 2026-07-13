//
//  BasicExampleController.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import Foundation
import Navi

@Observable
final class BasicExampleController: NaviController {
    var properties = NaviControllerProperties(logger: BasicLogger())
}

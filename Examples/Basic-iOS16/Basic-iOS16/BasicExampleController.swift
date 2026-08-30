//
//  BasicExampleController.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import Combine
import Foundation
import Navi

@MainActor
final class BasicExampleController: NaviController, ObservableObject {
    @Published var properties = NaviControllerProperties(logger: BasicLogger())
}

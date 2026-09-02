//
//  NavigationController.swift
//  Coordinators
//
//  Created by David Pall on 2026. 07. 13..
//

import Foundation
import Navi

@Observable
final class NavigationController: NaviController {
    
    // MARK: - Properties
    
    var properties: NaviControllerProperties
    
    // MARK: - Lifecycle
    
    init() {
        properties = NaviControllerProperties(logger: NavigationLogger())
    }
    
    // MARK: - Public functions
    
//    func push(_ screen: any ScreenRepresentable) {
//        push(to: screen)
//    }
//    
//    func start(_ coordinator: any CoordinatorRepresentable) {
//        push(to: coordinator)
//    }
}

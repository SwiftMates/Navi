//
//  MainTabViewModel.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import Foundation
import Navi

@Observable
final class MainTabViewModel {
    
    // MARK: - Nested types
    
    enum Tabs {
        case home, deeplinks
    }
    
    // MARK: - Public properties
    
    var selectedTab: Tabs = .home
    
    let deeplinkManager: any DeeplinkManagerProtocol = DeeplinkManager()
    let homeTabNavigationController = NavigationController()
    
    // MARK: - Public functions
    
    // TODO: - Make it async and add loader
    func onDeeplinkReceived(_ deeplink: Deeplink) {
        switch deeplink {
        case .homeTab:
            selectedTab = .home
            let route = deeplinkManager.handle(deeplink)
            homeTabNavigationController.deepLink(to: route)
        case .deeplinkTab:
            selectedTab = .deeplinks
        }
    }
}

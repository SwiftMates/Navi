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
    var isDeeplinkLoading: Bool = false
    
    let deeplinkManager = DeeplinkManager()
    let homeTabNavigationController = NavigationController()
    let deeplinksTabNavigationController = NavigationController()
    
    // MARK: - Public functions
    
    func onDeeplinkReceived(_ deeplink: Deeplink) async {
        isDeeplinkLoading = true
        
        defer {
            isDeeplinkLoading = false
        }
        
        let route = await deeplinkManager.handle(deeplink)
        
        switch deeplink {
        case .homeTab:
            selectedTab = .home
            homeTabNavigationController.deepLink(to: route)
        case .deeplinkTab:
            selectedTab = .deeplinks
            deeplinksTabNavigationController.deepLink(to: route)
        }
    }
}

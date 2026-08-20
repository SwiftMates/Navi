//
//  MainTabViewModel.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import Foundation

@Observable
final class MainTabViewModel {
    
    // MARK: - Nested types
    
    enum Tabs {
        case one, two, three
    }
    
    // MARK: - Public properties
    
    var selectedTab: Tabs = .one
}

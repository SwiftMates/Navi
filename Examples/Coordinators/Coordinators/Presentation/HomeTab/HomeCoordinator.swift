//
//  HomeCoordinator.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import Navi

struct HomeCoordinator {
    
    // MARK: - Nested types
    
    @DestinationRepresentable
    enum Coordinators {
        case aFlow
    }
    
    // MARK: - Public properties
    
    let manager: NavigationController
    
    // MARK: - Lifecycle
    
    init(manager: NavigationController) {
        self.manager = manager
    }
    
    // MARK: - Public functions
    
    func onHomeViewAction(_ action: HomeViewModel.Action) {
        switch action {
        case .onShowAFlow: manager.push(to: Coordinators.aFlow)
        }
    }
}

//
//  DeeplinksCoordinator.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import Navi

struct DeeplinksCoordinator {
    
    // MARK: - Nested types
    
    @DestinationRepresentable
    enum Coordinators {
        case bFlow
    }
    
    // MARK: - Public properties
    
    let manager: NavigationController
    
    // MARK: - Lifecycle
    
    init(manager: NavigationController) {
        self.manager = manager
    }
    
    // MARK: - Public functions
    
    func onDeeplinksViewAction(_ action: DeeplinksViewModel.Action) {
        switch action {
        
        }
    }
    
    func onBFlowFinish() {
        manager.popToRoot()
    }
}

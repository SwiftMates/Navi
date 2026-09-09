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
        case .showBFlowOnHome:
            deeplinkPublisher.go(to: .homeTab(.startBFlow))
        case .showStepTwoOfAFlowOnHome:
            deeplinkPublisher.go(to: .homeTab(.stepTwoOfAFlow))
        case .showBFlowOnDeeplinks:
            deeplinkPublisher.go(to: .deeplinkTab(.startBFlow))
        }
    }
    
    func onBFlowFinished() {
        manager.popToRoot()
    }
}

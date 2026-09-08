//
//  HomeTabDeeplinkBuilder.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import Navi

struct HomeTabDeeplinkBuilder {
    
    // MARK: - Public functions
    
    func build(for deeplink: HomeTabDeeplink) -> [any DestinationRepresentable] {
        switch deeplink {
        case .startBFlow: startOfBFlowRoute
        }
    }
    
    // MARK: - Private functions
    
    private var startOfBFlowRoute: [any DestinationRepresentable] {
        [
            HomeCoordinator.Coordinators.aFlow,
            AFlowCoordinator.Destination.stepTwo,
            AFlowCoordinator.Destination.stepThree,
            AFlowCoordinator.Coordinators.bFlow
        ]
    }
}

//
//  DeeplinksTabDeeplinkBuilder.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import Navi

struct DeeplinksTabDeeplinkBuilder {
    
    // MARK: - Public functions
    
    func build(for deeplink: DeeplinkTabDeeplink) async -> [any DestinationRepresentable] {
        switch deeplink {
        case .startBFlow: startOfBFlowRoute
        }
    }
    
    // MARK: - Private functions
    
    private var startOfBFlowRoute: [any DestinationRepresentable] {
        [
            DeeplinksCoordinator.Coordinators.bFlow
        ]
    }
}

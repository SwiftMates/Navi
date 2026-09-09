//
//  HomeTabDeeplinkBuilder.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import Navi

struct HomeTabDeeplinkBuilder {
    
    // MARK: - Public functions
    
    func build(for deeplink: HomeTabDeeplink) async -> [any DestinationRepresentable] {
        switch deeplink {
        case .startBFlow: startOfBFlowRoute
        case .stepTwoOfAFlow: await stepTwoOfAFlowRoute()
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
    
    private func stepTwoOfAFlowRoute() async -> [any DestinationRepresentable] {
        // Simulating network requests and gathering neccessary data
        try? await Task.sleep(for: .seconds(2))
        
        return [
            HomeCoordinator.Coordinators.aFlow,
            AFlowCoordinator.Destination.stepTwo
        ]
    }
}

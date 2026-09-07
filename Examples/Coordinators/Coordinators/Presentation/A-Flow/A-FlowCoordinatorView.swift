//
//  A-FlowCoordinatorView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import SwiftUI

struct AFlowCoordinatorView: View {
    
    // MARK: - Properties
    
    private let coordinator: AFlowCoordinator
    
    // MARK: - Lifecycle
    
    init(manager: NavigationController) {
        self.coordinator = AFlowCoordinator(manager: manager)
    }
    
    // MARK: - Content
    
    var body: some View {
        starterView
            .navigationDestination(
                for: AFlowCoordinator.Destination.self,
                destination: destination(for:)
            )
            .navigationDestination(
                for: AFlowCoordinator.Coordinators.self,
                destination: destination(for:)
            )
    }
    
    // MARK: - Private functions
    
    private var starterView: some View {
        AFlowStepOneView(action: coordinator.onStepOne)
    }
    
    @ViewBuilder
    private func destination(for destination: AFlowCoordinator.Destination) -> some View {
        switch destination {
        case .stepTwo: AFlowStepTwoView(action: coordinator.onStepTwo)
        case .stepThree: AFlowStepThreeView(action: coordinator.onStepThree)
        }
    }
    
    @ViewBuilder
    private func destination(for childCoordinator: AFlowCoordinator.Coordinators) -> some View {
        switch childCoordinator {
        case .bFlow: BFlowCoordinatorView(manager: coordinator.manager)
        }
    }
}

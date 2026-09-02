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
    }
    
    // MARK: - Private functions
    
    private var starterView: some View {
        AFlowStepOneView(action: coordinator.onStepOne(action:))
    }
    
    @ViewBuilder
    private func destination(for destination: AFlowCoordinator.Destination) -> some View {
        switch destination {
        case .stepOne: AFlowStepOneView(action: coordinator.onStepOne(action:))
        case .stepTwo: AFlowStepTwoView(action: coordinator.onStepTwo(action:))
        case .stepThree: AFlowStepThreeView(action: coordinator.onStepThree(action:))
        }
    }
}

//
//  BFlowCoordinatorView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//


import SwiftUI

struct BFlowCoordinatorView: View {
    
    // MARK: - Properties
    
    private let coordinator: BFlowCoordinator
    
    // MARK: - Lifecycle
    
    init(manager: NavigationController) {
        self.coordinator = BFlowCoordinator(manager: manager)
    }
    
    // MARK: - Content
    
    var body: some View {
        starterView
            .navigationDestination(
                for: BFlowCoordinator.Destination.self,
                destination: destination(for:)
            )
    }
    
    // MARK: - Private functions
    
    private var starterView: some View {
        BFlowStepOneView(action: coordinator.onStepOne)
    }
    
    @ViewBuilder
    private func destination(for destination: BFlowCoordinator.Destination) -> some View {
        switch destination {
        case .stepTwo: BFlowStepTwoView(action: coordinator.onStepTwo)
        case .stepThree: BFlowStepThreeView(action: coordinator.onStepThree)
        }
    }
}

//
//  DeeplinksCoordinatorView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import SwiftUI

struct DeeplinksCoordinatorView: View {
    
    // MARK: - Properties
    
    private let coordinator: DeeplinksCoordinator
    
    // MARK: - Lifecycle
    
    init(manager: NavigationController) {
        self.coordinator = DeeplinksCoordinator(manager: manager)
    }
    
    // MARK: - Content
    
    var body: some View {
        starterView
            .navigationDestination(
                for: DeeplinksCoordinator.Coordinators.self,
                destination: destination(for:)
            )
    }
    
    // MARK: - Private functions
    
    private var starterView: some View {
        DeeplinksView(action: coordinator.onDeeplinksViewAction)
    }
    
    @ViewBuilder
    private func destination(for childCoordinator: DeeplinksCoordinator.Coordinators) -> some View {
        switch childCoordinator {
        case .bFlow:
            BFlowCoordinatorView(
                manager: coordinator.manager,
                onFinish: coordinator.onBFlowFinish
            )
        }
    }
}

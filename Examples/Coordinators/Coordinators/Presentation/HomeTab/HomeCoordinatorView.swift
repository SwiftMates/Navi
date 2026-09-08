//
//  HomeCoordinatorView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import SwiftUI

struct HomeCoordinatorView: View {
    
    // MARK: - Properties
    
    private let coordinator: HomeCoordinator
    
    // MARK: - Lifecycle
    
    init(manager: NavigationController) {
        self.coordinator = HomeCoordinator(manager: manager)
    }
    
    // MARK: - Content
    
    var body: some View {
        starterView
            .navigationDestination(
                for: HomeCoordinator.Coordinators.self,
                destination: destination(for:)
            )
    }
    
    // MARK: - Private functions
    
    private var starterView: some View {
        HomeView(action: coordinator.onHomeViewAction)
    }
    
    @ViewBuilder
    private func destination(for childCoordinator: HomeCoordinator.Coordinators) -> some View {
        switch childCoordinator {
        case .aFlow: AFlowCoordinatorView(manager: coordinator.manager)
        }
    }
}

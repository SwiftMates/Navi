//
//  A-FlowCoordinator.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import Navi

struct AFlowCoordinator {
    
    // MARK: - Nested types

    @DestinationRepresentable
    enum Destination {
        case stepTwo
        @OriginKey case stepThree
    }
    
    // TODO: - Discuss if we should merge all destinations into one Enum (screens and other coordinators togehter)
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
    
    func onStepOne(_ action: AFlowStepOneViewModel.Action) {
        switch action {
        case .nextButtonTapped:
            manager.push(to: Destination.stepTwo)
        }
    }
    
    func onStepTwo(_ action: AFlowStepTwoViewModel.Action) {
        switch action {
        case .nextButtonTapped:
            manager.push(to: Destination.stepThree)
        }
    }
    
    func onStepThree(_ action: AFlowStepThreeViewModel.Action) {
        switch action {
        case .showNextCoordinator:
            manager.push(to: Coordinators.bFlow)
        case .goHome:
            manager.popToRoot()
        }
    }
    
    func onBFlowFinish() {
        manager.pop(to: Destination.Origins.stepThree)
    }
}

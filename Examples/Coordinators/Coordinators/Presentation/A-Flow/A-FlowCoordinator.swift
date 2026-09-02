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
        case stepOne
        case stepTwo
        case stepThree
    }
    
    // MARK: - Public properties
    
    let manager: NavigationController
    
    // MARK: - Lifecycle
    
    init(manager: NavigationController) {
        self.manager = manager
    }
    
    // MARK: - Public functions
    
    func onStepOne(action: AFlowStepOneViewModel.Action) {
        switch action {
        case .nextButtonTapped:
            manager.push(to: Destination.stepTwo)
        }
    }
    
    func onStepTwo(action: AFlowStepTwoViewModel.Action) {
        switch action {
        case .nextButtonTapped:
            manager.push(to: Destination.stepThree)
        }
    }
    
    func onStepThree(action: AFlowStepThreeViewModel.Action) {
        switch action {
        case .doneButtonTapped:
            manager.popToRoot()
        }
    }
}

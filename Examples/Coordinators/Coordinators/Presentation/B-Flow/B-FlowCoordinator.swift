//
//  BFlowCoordinator.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//


import Navi

struct BFlowCoordinator {
    
    // MARK: - Nested types

    @DestinationRepresentable
    enum Destination {
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
    
    func onStepOne(_ action: BFlowStepOneViewModel.Action) {
        switch action {
        case .nextButtonTapped:
            manager.push(to: Destination.stepTwo)
        }
    }
    
    func onStepTwo(_ action: BFlowStepTwoViewModel.Action) {
        switch action {
        case .nextButtonTapped:
            manager.push(to: Destination.stepThree)
        }
    }
    
    func onStepThree(_ action: BFlowStepThreeViewModel.Action) {
        switch action {
        case .doneButtonTapped:
            manager.popToRoot()
        }
    }
}

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
    
    // MARK: - Private properties
    
    private let onFinish: () -> Void
    
    // MARK: - Lifecycle
    
    init(
        manager: NavigationController,
        onFinish: @escaping () -> Void
    ) {
        self.manager = manager
        self.onFinish = onFinish
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
        case .finish:
            onFinish()
        case .goToRoot:
            manager.popToRoot()
        }
    }
}

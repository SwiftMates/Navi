//
//  A-FlowStepOneViewModel.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import Foundation

@Observable
final class AFlowStepOneViewModel {
    
    // MARK: - Nested types
    
    enum Action {
        case nextButtonTapped
    }
    
    // MARK: - Public properties
    
    let action: (Action) -> Void
    
    // MARK: - Lifecycle
    
    init(action: @escaping (Action) -> Void) {
        self.action = action
    }
    
    // MARK: - Public properties
    
    func onNextButtonTapped() {
        action(.nextButtonTapped)
    }
}

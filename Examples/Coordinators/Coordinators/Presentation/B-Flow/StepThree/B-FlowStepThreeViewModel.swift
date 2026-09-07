//
//  BFlowStepThreeViewModel.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import Foundation

@Observable
final class BFlowStepThreeViewModel {
    
    // MARK: - Nested types
    
    enum Action {
        case doneButtonTapped
    }
    
    // MARK: - Public properties
    
    let action: (Action) -> Void
    
    // MARK: - Lifecycle
    
    init(action: @escaping (Action) -> Void) {
        self.action = action
    }
    
    // MARK: - Public properties
    
    func onDoneButtonTapped() {
        action(.doneButtonTapped)
    }
}

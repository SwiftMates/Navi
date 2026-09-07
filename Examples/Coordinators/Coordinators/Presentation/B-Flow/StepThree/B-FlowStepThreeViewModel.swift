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
        case finish
        case goHome
    }
    
    // MARK: - Public properties
    
    let action: (Action) -> Void
    
    // MARK: - Lifecycle
    
    init(action: @escaping (Action) -> Void) {
        self.action = action
    }
    
    // MARK: - Public properties
    
    func onFinishCoordinator() {
        action(.finish)
    }
    
    func onGoHomeTapped() {
        action(.goHome)
    }
}

//
//  HomeViewModel.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

final class HomeViewModel {
    
    // MARK: - Nested types
    
    enum Action {
        case onShowAFlow
    }
    
    // MARK: - Public properties
    
    let action: (Action) -> Void
    
    // MARK: - Lifecycle
    
    init(action: @escaping (Action) -> Void) {
        self.action = action
    }
    
    // MARK: - Public functions
    
    func onShowAFlowTapped() {
        action(.onShowAFlow)
    }
}

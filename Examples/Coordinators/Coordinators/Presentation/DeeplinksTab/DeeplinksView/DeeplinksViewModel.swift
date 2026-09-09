//
//  DeeplinksViewModel.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import Navi

final class DeeplinksViewModel {
    
    // MARK: - Nested types
    
    enum Action {
        case showBFlowOnHome
        case showStepTwoOfAFlowOnHome
        case showBFlowOnDeeplinks
    }
    
    // MARK: - Public properties
    
    let action: (Action) -> Void
    
    // MARK: - Lifecycle
    
    init(action: @escaping (Action) -> Void) {
        self.action = action
    }
    
    // MARK: - Public functions
    
    func onShowBFlowOnHomeTapped() {
        action(.showBFlowOnHome)
    }
    
    func onShowStepTwoOfAFlowOnHome() {
        action(.showStepTwoOfAFlowOnHome)
    }
    
    func onShowBFlowOnDeeplinks() {
        action(.showBFlowOnDeeplinks)
    }
}

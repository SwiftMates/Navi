//
//  AFlowStepThreeView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import SwiftUI

struct AFlowStepThreeView: View {
    
    // MARK: - Properties
    
    private let viewModel: AFlowStepThreeViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (AFlowStepThreeViewModel.Action) -> Void) {
        viewModel = .init(action: action)
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 24) {
                ButtonWithExplanation(
                    title: "Next",
                    description: "Starts the B-Flow coordinator with its starter view.",
                    action: viewModel.onShowNextCoordinatorPressed
                )
                
                ButtonWithExplanation(
                    title: "Go home",
                    description: "Clears the navigation and pops back to the root.",
                    action: viewModel.onGoHomeTapped
                )
            }
        }
        .navigationTitle("A-Flow Step Three")
    }
}

//
//  BFlowStepThreeView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import SwiftUI

struct BFlowStepThreeView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: BFlowStepThreeViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (BFlowStepThreeViewModel.Action) -> Void) {
        _viewModel = State(initialValue: .init(action: action))
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
    
            VStack(spacing: 24) {
                ActionWithExplanationView(
                    title: "Finish",
                    description: "Closes the B-Flow coordinator.",
                    action: viewModel.onFinishCoordinator
                )
                
                ActionWithExplanationView(
                    title: "Go home",
                    description: "Clears the navigation and pops back to the root.",
                    action: viewModel.onGoToRootTapped
                )
            }
        }
        .navigationTitle("B-Flow Step Three")
    }
}

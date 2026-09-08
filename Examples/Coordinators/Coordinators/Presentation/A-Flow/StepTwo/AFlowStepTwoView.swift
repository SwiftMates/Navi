//
//  AFlowStepTwoView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import SwiftUI

struct AFlowStepTwoView: View {
    
    // MARK: - Properties
    
    private let viewModel: AFlowStepTwoViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (AFlowStepTwoViewModel.Action) -> Void) {
        viewModel = .init(action: action)
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.3).ignoresSafeArea()
            
            ActionWithExplanationView(
                title: "Next",
                description: "Navigates to A-Flow Step Three.",
                action: viewModel.onNextButtonTapped
            )
        }
        .navigationTitle("A-Flow Step Two")
    }
}

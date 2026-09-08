//
//  BFlowStepTwoView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import SwiftUI

struct BFlowStepTwoView: View {
    
    // MARK: - Properties
    
    private let viewModel: BFlowStepTwoViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (BFlowStepTwoViewModel.Action) -> Void) {
        viewModel = .init(action: action)
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            
            ActionWithExplanationView(
                title: "Next",
                description: "Navigates to B-Flow Step Three.",
                action: viewModel.onNextButtonTapped
            )
        }
        .navigationTitle("B-Flow Step Two")
    }
}

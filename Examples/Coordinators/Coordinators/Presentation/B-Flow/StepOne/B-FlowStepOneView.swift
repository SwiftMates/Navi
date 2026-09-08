//
//  BFlowStepOneView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import SwiftUI

struct BFlowStepOneView: View {
    
    // MARK: - Properties
    
    private let viewModel: BFlowStepOneViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (BFlowStepOneViewModel.Action) -> Void) {
        viewModel = .init(action: action)
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            
            ActionWithExplanationView(
                title: "Next",
                description: "Navigates to B-Flow Step Two.",
                action: viewModel.onNextButtonTapped
            )
        }
        .navigationTitle("B-Flow Step One")
    }
}

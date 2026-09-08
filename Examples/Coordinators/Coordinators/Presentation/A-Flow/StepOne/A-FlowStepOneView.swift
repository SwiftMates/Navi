//
//  A-FlowStepOneView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import SwiftUI

struct AFlowStepOneView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: AFlowStepOneViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (AFlowStepOneViewModel.Action) -> Void) {
        _viewModel = State(initialValue: .init(action: action))
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.3).ignoresSafeArea()
            
            ActionWithExplanationView(
                title: "Next",
                description: "Navigates to A-Flow Step Two.",
                action: viewModel.onNextButtonTapped
            )
        }
        .navigationTitle("A-Flow Step One")
    }
}

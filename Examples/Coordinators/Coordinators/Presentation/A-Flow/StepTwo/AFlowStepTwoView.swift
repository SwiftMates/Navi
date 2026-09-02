//
//  AFlowStepTwoView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import SwiftUI

struct AFlowStepTwoView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: AFlowStepTwoViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (AFlowStepTwoViewModel.Action) -> Void) {
        _viewModel = State(initialValue: .init(action: action))
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack {
            Button("Show next step") {
                viewModel.onNextButtonTapped()
            }
        }
        .navigationTitle("A-Flow Step Two")
    }
}

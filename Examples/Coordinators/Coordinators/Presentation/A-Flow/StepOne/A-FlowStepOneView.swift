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
        VStack {
            Button("Show next step") {
                viewModel.onNextButtonTapped()
            }
        }
        .navigationTitle("A-Flow Step One")
    }
}

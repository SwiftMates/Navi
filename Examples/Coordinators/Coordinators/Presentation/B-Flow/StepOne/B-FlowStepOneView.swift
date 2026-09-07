//
//  BFlowStepOneView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import SwiftUI

struct BFlowStepOneView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: BFlowStepOneViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (BFlowStepOneViewModel.Action) -> Void) {
        _viewModel = State(initialValue: .init(action: action))
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack {
            Button("Show step two") {
                viewModel.onNextButtonTapped()
            }
        }
        .navigationTitle("B-Flow Step One")
    }
}

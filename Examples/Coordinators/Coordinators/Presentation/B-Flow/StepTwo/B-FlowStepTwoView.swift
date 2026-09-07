//
//  BFlowStepTwoView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import SwiftUI

struct BFlowStepTwoView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: BFlowStepTwoViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (BFlowStepTwoViewModel.Action) -> Void) {
        _viewModel = State(initialValue: .init(action: action))
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            
            Button("Show step three") {
                viewModel.onNextButtonTapped()
            }
        }
        .navigationTitle("B-Flow Step Two")
    }
}

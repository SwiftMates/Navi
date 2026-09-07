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
        VStack {
            Button("Done") {
                viewModel.onDoneButtonTapped()
            }
        }
        .navigationTitle("B-Flow Step Three")
    }
}

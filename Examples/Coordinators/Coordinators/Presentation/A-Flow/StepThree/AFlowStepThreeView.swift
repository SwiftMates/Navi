//
//  AFlowStepThreeView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import SwiftUI

struct AFlowStepThreeView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: AFlowStepThreeViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (AFlowStepThreeViewModel.Action) -> Void) {
        _viewModel = State(initialValue: .init(action: action))
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack {
            Button("Done") {
                viewModel.ondoneButtonTapped()
            }
        }
        .navigationTitle("A-Flow Step Three")
    }
}

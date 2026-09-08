//
//  DeeplinksView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import SwiftUI

struct DeeplinksView: View {
    
    // MARK: - Properties
    
    private let viewModel: DeeplinksViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (DeeplinksViewModel.Action) -> Void) {
        viewModel = DeeplinksViewModel(action: action)
    }
    
    // MARK: - Content
    
    var body: some View {
        content
            .navigationTitle("Deeplinks")
    }
    
    private var content: some View {
        Form {
            deeplinkRowView(
                title: "A-Flow: Step two (Home tab)",
                description: "Simulates asynchronous data loading.\nNavigates to Step Two of the A-Flow on the Home tab.",
                action: viewModel.onShowStepTwoOfAFlowOnHome)

            deeplinkRowView(
                title: "B-Flow: Start (Home tab)",
                description: "Immediate navigation.\nNavigates to the start of the B-Flow on the Home tab (following the A-Flow).",
                action: viewModel.onShowBFlowOnHomeTapped)
            
            deeplinkRowView(
                title: "B-Flow: Start (Deeplinks tab)",
                description: "Immediate navigation.\nNavigates to the start of the B-Flow on the Deeplinks tab.",
                action: viewModel.onShowBFlowOnDeeplinks)
        }
    }
    
    private func deeplinkRowView(
        title: String,
        description: String,
        action: @escaping () -> Void
    ) -> some View {
        Section {
            Button(title, action: action)
        } footer: {
            Text(description)
        }
    }
}

#Preview {
    DeeplinksView(action: {_ in })
}

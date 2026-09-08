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
        ZStack {
            Color.orange.opacity(0.3).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    sectionTitle(for: "On Home Tab")
                    
                    ActionWithExplanationView(
                        title: "A-Flow: Step two",
                        description: "Simulates asynchronous data loading.\nNavigates to Step Two of the A-Flow on the Home tab.",
                        action: viewModel.onShowStepTwoOfAFlowOnHome)
                    
                    ActionWithExplanationView(
                        title: "B-Flow: Start",
                        description: "Immediate navigation.\nNavigates to the start of the B-Flow on the Home tab (following the A-Flow).",
                        action: viewModel.onShowBFlowOnHomeTapped)
                    
                    Divider()
                    
                    sectionTitle(for: "On Deeplinks Tab")
                    
                    ActionWithExplanationView(
                        title: "B-Flow: Start",
                        description: "Immediate navigation.\nNavigates to the start of the B-Flow on the Deeplinks tab.",
                        action: viewModel.onShowBFlowOnDeeplinks)
                }
            }
            .scrollIndicators(.hidden)
            .contentMargins(.vertical, 24, for: .scrollContent)
        }
    }
    
    private func sectionTitle(for title: String) -> some View {
        Text(title)
            .font(.title2)
            .bold()
            .foregroundStyle(.secondary)
            .padding(.horizontal, 24)
    }
}

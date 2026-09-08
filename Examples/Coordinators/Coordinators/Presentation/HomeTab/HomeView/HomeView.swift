//
//  HomeView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (HomeViewModel.Action) -> Void) {
        viewModel = HomeViewModel(action: action)
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            Color.teal.opacity(0.3).ignoresSafeArea()
            
            ActionWithExplanationView(
                title: "Start A-Flow",
                description: "Starts the A-Flow coordinator with its starter view.",
                action: viewModel.onShowAFlowTapped)
        }
        .navigationTitle("Home")
    }
}

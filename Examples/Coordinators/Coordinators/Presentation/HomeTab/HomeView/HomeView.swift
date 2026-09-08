//
//  HomeView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 07..
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Properties
    
    @State private var viewModel: HomeViewModel
    
    // MARK: - Lifecycle
    
    init(action: @escaping (HomeViewModel.Action) -> Void) {
        _viewModel = State(initialValue: .init(action: action))
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack {
            Button("Show A-Flow") {
                viewModel.onShowAFlowTapped()
            }
        }
        .navigationTitle("Home")
    }
}

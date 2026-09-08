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
        VStack {
            
        }
        .navigationTitle("Deeplinks")
    }
}

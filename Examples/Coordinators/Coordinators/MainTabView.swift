//
//  MainTabView.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - Properties
    
    @State private var viewModel = MainTabViewModel()
    
    // MARK: - Content
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("Home", systemImage: "house", value: .one) {
                NavigationStackWrapper { HomeCoordinatorView(manager: $0) }
            }
            
            Tab("Deeplinks", systemImage: "link", value: .two) {
                Text("Deeplinks")
            }
        }
    }
}

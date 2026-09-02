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
            Tab("One", systemImage: "1.circle", value: .one) {
                NavigationStackWrapper { AFlowCoordinatorView(manager: $0) }
            }
            
            Tab("Two", systemImage: "2.circle", value: .two) {
                Text("Tab two")
            }
            
            Tab("Three", systemImage: "3.circle", value: .three) {
                Text("Tab three")
            }
        }
    }
}

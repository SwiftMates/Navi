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
            Tab("Home", systemImage: "house", value: .home) {
                NavigationStackWrapper(manager: viewModel.homeTabNavigationController) {
                    HomeCoordinatorView(manager: $0)
                }
            }
            
            Tab("Deeplinks", systemImage: "link", value: .deeplinks) {
                Button {
                    deeplinkPublisher.go(to: .homeTab(.startBFlow))
                } label: {
                    Text("Try deeplink")
                }
            }
        }
        .onReceive(
            deeplinkPublisher.publisher,
            perform: viewModel.onDeeplinkReceived
        )
    }
}

//
//  NavigationStackWrapper.swift
//  Coordinators
//
//  Created by David Pall on 2026. 08. 20..
//

import SwiftUI
import Navi

struct NavigationStackWrapper<Content: View>: View {
    
    // MARK: - Properties
    
    @State private var manager: NavigationController
    let content: (NavigationController) -> Content
    
    // MARK: - Lifecycle

    init(
        manager: NavigationController,
        @ViewBuilder content: @escaping (NavigationController) -> Content
    ) {
        _manager = State(initialValue: manager)
        self.content = content
    }

    init(
        @ViewBuilder content: @escaping (NavigationController) -> Content
    ) {
        _manager = State(initialValue: NavigationController())
        self.content = content
    }
    
    // MARK: - Content
    
    var body: some View {
        NavigationStack(path: $manager.properties.path) {
            content(manager)
                .toolbarVisibility(manager.properties.path.isEmpty ? .visible : .hidden, for: .tabBar)
        }
    }
}

//
//  View-A.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

struct ViewA: View {
    
    @Environment(Coordinator.self) var coordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Show View - B") {
                coordinator.push(to: ViewADestinations.viewB)
            }

            Button("Pop") {
                coordinator.pop()
            }
        }
        .navigationTitle("View - A")
        .navigationDestination(for: ViewADestinations.self) { destination in
            switch destination {
            case .viewB: ViewB()
            }
        }
    }
}

enum ViewADestinations: Navigable {
    case viewB
}

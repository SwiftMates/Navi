//
//  View-B.swift
//  Navi Plain SwiftUI example
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

struct ViewB: View {
    
    @Environment(Coordinator.self) var coordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Show View - C") {
                coordinator.push(to: ViewBDestinations.viewC)
            }

            Button("Pop") {
                coordinator.pop()
            }
        }
        .navigationTitle("View - B")
        .navigationDestination(for: ViewBDestinations.self) { destination in
            switch destination {
            case .viewC: ViewC()
            }
        }
    }
}

enum ViewBDestinations: Navigable {
    case viewC
}

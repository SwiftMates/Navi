//
//  View-A.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

struct ViewA: View {
    
    @EnvironmentObject var controller: BasicExampleController
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Show View - B") {
                controller.push(to: ViewADestinations.viewB)
            }

            Button("Pop") {
                controller.pop()
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

@DestinationRepresentable
enum ViewADestinations {
    case viewB
}

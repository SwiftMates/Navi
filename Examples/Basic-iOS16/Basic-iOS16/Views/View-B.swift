//
//  View-B.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

struct ViewB: View {
    
    @EnvironmentObject var controller: BasicExampleController
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Show View - C") {
                controller.push(to: ViewBDestinations.viewC)
            }

            Button("Pop") {
                controller.pop()
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

@DestinationRepresentable
enum ViewBDestinations {
    case viewC
}

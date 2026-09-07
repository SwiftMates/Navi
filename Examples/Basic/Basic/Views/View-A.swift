//
//  View-A.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import Navi
import SwiftUI

struct ViewA: View {

    @Environment(BasicExampleController.self) var controller

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

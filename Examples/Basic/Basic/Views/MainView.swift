//
//  MainView.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

struct MainView: View {
    
    @Environment(BasicExampleController.self) var controller
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Show View - A") {
                controller.push(to: MainViewsDestinations.viewA)
            }

            Button("Deeplink to View - C") {
                controller.deepLink(to: [
                    MainViewsDestinations.viewA,
                    ViewADestinations.viewB,
                    ViewBDestinations.viewC
                ])
            }
        }
        .navigationTitle("Main view")
        .navigationDestination(for: MainViewsDestinations.self) { destination in
            switch destination {
            case .viewA: ViewA()
            }
        }
    }
}

@Destination
enum MainViewsDestinations {
    @Origin case viewA
}

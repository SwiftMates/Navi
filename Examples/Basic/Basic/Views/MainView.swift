//
//  MainView.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

struct MainView: View {
    
    @Environment(Coordinator.self) var coordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Show View - A") {
                coordinator.push(to: MainViewsDestinations.viewA)
            }

            Button("Deeplink to View - C") {
                coordinator.deeplink(to: [
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

enum MainViewsDestinations: Navigable {
    case viewA
    
    var navigationOrigin: NaviStackOriginKeys? {
        switch self {
        case .viewA: return NaviStackOriginKeys.viewA
        }
    }
}

extension NaviStackOriginKeys {
    static let viewA = NaviStackOriginKeys(debugName: "View - A Origin")
}

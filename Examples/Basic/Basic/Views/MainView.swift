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

enum MainViewsDestinations: DestinationRepresentable {
    case viewA
    
    var navigationOrigin: (any OriginRepresentable)? {
        switch self {
        case .viewA: return Origins.viewA
        }
    }
    
    enum Origins: OriginRepresentable {
        case viewA
        
        var key: NavigationOriginKey {
            switch self {
            case .viewA: Self.viewAOriginKey
            }
        }
    
        static private let viewAOriginKey = NavigationOriginKey(debugName: "View - A Origin")
    }
}

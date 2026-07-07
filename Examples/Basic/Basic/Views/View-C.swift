//
//  View-C.swift
//  Navi Plain SwiftUI example
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

struct ViewC: View {
    
    @Environment(Coordinator.self) var coordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Pop") {
                coordinator.pop()
            }
            
            Button("Pop to View - A") {
                coordinator.pop(to: .viewA)
            }
            
            Button("Pop to root") {
                coordinator.popToRoot()
            }
        }
        .navigationTitle("View - C")
    }
}

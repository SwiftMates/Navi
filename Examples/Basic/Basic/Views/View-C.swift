//
//  View-C.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

struct ViewC: View {
    
    @Environment(BasicExampleController.self) var controller
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Pop") {
                controller.pop()
            }
            
            Button("Pop to View - A") {
                controller.pop(to: MainViewsDestinations.Origins.viewA)
            }
            
            Button("Pop to root") {
                controller.popToRoot()
            }
        }
        .navigationTitle("View - C")
    }
}

//
//  View-C.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import Navi
import SwiftUI

struct ViewC: View {

    @EnvironmentObject var controller: BasicExampleController

    var body: some View {
        VStack(spacing: 24) {
            Button("Pop to View - A") {
                controller.pop(to: MainViewsDestinations.Origins.viewA)
            }

            Button("Pop") {
                controller.pop()
            }

            Button("Pop to root") {
                controller.popToRoot()
            }
        }
        .navigationTitle("View - C")
    }
}

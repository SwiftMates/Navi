//
//  BasicApp.swift
//  Basic
//
//  Created by David Pall on 2026. 07. 07..
//

import SwiftUI
import Navi

@main
struct BasicApp: App {
    
    @State private var coordinator = Coordinator()
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                NavigationStack(path: $coordinator.properties.path) {
                    MainView()
                }
                
                DebugView(viewCount: coordinator.properties.path.count)
            }
            .environment(coordinator)
        }
    }
}

struct DebugView: View {
    
    let viewCount: Int
    
    var body: some View {
        Text("Elements in stack: \(viewCount)")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
    }
}

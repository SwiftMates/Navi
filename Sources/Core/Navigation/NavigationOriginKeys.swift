//
//  NavigationStackOriginKeys.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import Foundation

public struct NavigationOriginKeys: Hashable, Sendable {
    let id = UUID()
    var debugName: String?
    
    // MARK: - Lifecycle
    
    public init(debugName: String? = nil) {
        self.debugName = debugName
    }
}

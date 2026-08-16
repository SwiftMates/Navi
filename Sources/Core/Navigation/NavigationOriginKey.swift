//
//  NavigationStackOriginKey.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import Foundation

/// A unique key used to mark and reference a navigation origin in the stack.
///
/// Use this type to tag destinations so the controller can later pop back to a known point.
public struct NavigationOriginKey: Hashable, Sendable {
    let id = UUID()
    var debugName: String?
    
    // MARK: - Lifecycle
    
    /// Creates a new unique navigation origin key.
    ///
    /// - Parameter debugName: An optional developer-facing label to aid debugging.
    public init(debugName: String? = nil) {
        self.debugName = debugName
    }
}

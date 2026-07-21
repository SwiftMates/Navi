//
//  Navigable.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

/// A type that can be represented as a destination in the navigation stack.
///
/// Conforming types are hashable so they can be stored in SwiftUI navigation paths,
/// and may optionally expose an origin key for keyed pop operations.
public protocol DestinationRepresentable: Hashable {
    /// An optional origin marker used by the controller to track stack positions.
    var navigationOrigin: NavigationOriginKey { get }
}

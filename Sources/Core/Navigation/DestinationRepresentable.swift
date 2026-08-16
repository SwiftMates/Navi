//
//  Navigable.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

// TODO: - Check documentation
/// A type that can be represented as a destination in the navigation stack.
///
/// Conforming types are hashable so they can be stored in SwiftUI navigation paths,
/// and may optionally expose an origin representable for keyed pop operations.
public protocol DestinationRepresentable: Hashable {
    /// An optional origin marker used by the controller to track stack positions.
    var navigationOrigin: (any OriginRepresentable)? { get }
}

// MARK: - Default Implementation

// TODO: - Check documentation
public extension DestinationRepresentable {
    /// The default origin marker for a destination.
    ///
    /// Conforming types can override this to provide a `NavigationOriginKey` when
    /// they want to be used as a pop target.
    var navigationOrigin: (any OriginRepresentable)? { nil }
}

//
//  Navigable.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

/// A type that can be represented as a destination in the navigation stack.
///
/// Conforming types are hashable so they can be stored in a SwiftUI `NavigationPath`,
/// and may optionally expose an ``OriginRepresentable`` value via ``navigationOrigin``
/// to mark their position in the stack for keyed pop operations.
public protocol DestinationRepresentable: Hashable {
    /// An optional origin marker used by the controller to track this destination's position in the stack.
    ///
    /// When non-`nil`, the controller records the destination's index under the origin's
    /// ``OriginRepresentable/key`` at push time, allowing later navigation back to this point
    /// via ``NaviController/pop(to:)``.
    var navigationOrigin: (any OriginRepresentable)? { get }
}

// MARK: - Default Implementation

public extension DestinationRepresentable {
    /// The default origin marker for a destination.
    ///
    /// Returns `nil` by default. Conforming types can override this to provide an
    /// ``OriginRepresentable`` value when they want to be used as a pop target.
    var navigationOrigin: (any OriginRepresentable)? { nil }
}

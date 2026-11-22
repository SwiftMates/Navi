//
//  OriginRepresentable.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 16/08/2026.
//

/// A type that marks a location within the navigation stack that can be used as a pop target.
///
/// Conforming types expose a ``NavigationOriginKey`` that the navigation controller uses to
/// track a destination's position in the stack, enabling keyed pop operations via
/// ``NaviController/pop(to:)``.
public protocol OriginRepresentable {
    /// The unique key that identifies this origin within a navigation stack.
    ///
    /// The controller stores the path index of a pushed destination under this key, then looks it up
    /// again in ``NaviController/pop(to:)``. Each value must be stable for the lifetime of the origin,
    /// so conforming types normally store a ``NavigationOriginKey`` rather than creating one per access.
    var key: NavigationOriginKey { get }
}

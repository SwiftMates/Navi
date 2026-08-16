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
    var key: NavigationOriginKey { get }
}

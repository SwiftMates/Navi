//
//  NaviControllerProperties.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import SwiftUI

/// A container that stores mutable navigation state for a ``NaviController``.
///
/// `NaviControllerProperties` owns the current `NavigationPath` and internal bookkeeping
/// used by the controller to support keyed stack navigation.
///
/// The type is main-actor isolated: navigation state is only mutated on the main actor,
/// whether by the controller or by SwiftUI writing into the bound path.
@MainActor
public struct NaviControllerProperties {
    
    /// The current navigation path rendered by SwiftUI navigation containers.
    ///
    /// The path is the source of truth for the stack. Whenever it changes — including when
    /// SwiftUI mutates it directly for a system back button or swipe-to-go-back gesture —
    /// tracked navigation origins are reconciled so they only ever reference a valid index.
    public var path: NavigationPath {
        didSet {
            syncStackOrigins()
        }
    }

    /// Tracked positions of keyed navigation origins.
    ///
    /// Kept internal on purpose: `@MainActor` does not isolate plain stored properties of a
    /// value type, so exposing this would expose mutable state without isolation enforcement.
    /// Back it with an accessor before making it public.
    var naviStackOrigins: [NavigationOriginKey: Int]

    let logger: (any NaviLogging)?

    // MARK: - Lifecycle

    /// Creates a new set of controller properties with an empty navigation path.
    ///
    /// The initializer also prepares internal origin tracking and logger instances.
    public init(logger: (any NaviLogging)? = nil) {
        self.path = NavigationPath()
        self.naviStackOrigins = [:]
        self.logger = logger
    }

    // MARK: - Private methods

    /// Removes tracked navigation origins that no longer correspond to a valid path index.
    ///
    /// Called after every mutation of ``path`` so ``naviStackOrigins`` stays in sync with the
    /// current stack state, whether the change came from the controller or from SwiftUI
    /// writing into the bound path.
    private mutating func syncStackOrigins() {
        guard naviStackOrigins.isEmpty == false else { return }

        if path.isEmpty {
            naviStackOrigins.removeAll()
            logger?.logInfo("All navigation origins cleared.")
        } else {
            for (key, index) in naviStackOrigins where index > path.count {
                naviStackOrigins.removeValue(forKey: key)
                logger?.logInfo("Navigation origin removed: \(String(describing: key.debugName)) from index: \(index).")
            }
        }
    }
}

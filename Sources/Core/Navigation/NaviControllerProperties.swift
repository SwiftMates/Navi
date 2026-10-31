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
@MainActor
public struct NaviControllerProperties {
    
    /// The current navigation path rendered by SwiftUI navigation containers.
    ///
    /// When destinations are removed, tracked origins are reconciled — including when SwiftUI
    /// mutates the path directly for the system back button or swipe-to-go-back.
    public var path: NavigationPath {
        didSet {
            guard path.count < oldValue.count else { return }
            syncStackOrigins()
        }
    }

    /// Tracked positions of keyed navigation origins.
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

    /// Removes tracked navigation origins that no longer point to a valid path index.
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

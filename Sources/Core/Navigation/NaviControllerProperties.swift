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
public struct NaviControllerProperties {

    /// The current navigation path rendered by SwiftUI navigation containers.
    public var path: NavigationPath

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
}

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
    /// mutates the path directly for the system back button or swipe-to-go-back — and any
    /// installed back-navigation bridge is notified.
    public var path: NavigationPath {
        didSet {
            guard path.count < oldValue.count else { return }

            let removedCount = oldValue.count - path.count
            syncStackOrigins()

            // Snapshot and clear before notifying, so a mutation triggered from inside the
            // bridge cannot observe a stale source or have its own source overwritten.
            let source = currentSource
            currentSource = .systemOrGesture
            onPathDidShrink?(removedCount, path.count, source)
        }
    }

    /// Tracked positions of keyed navigation origins.
    var naviStackOrigins: [NavigationOriginKey: Int]

    let logger: (any NaviLogging)?

    // MARK: - Back-navigation bridge

    /// Notifies a controller that destinations were removed from the path.
    ///
    /// Installed by ``NaviController/enableBackNotifications()``. Internal plumbing — this is
    /// not part of the public API surface.
    var onPathDidShrink: ((Int, Int, NavigationBackSource) -> Void)?

    /// The source attributed to the next path reduction.
    ///
    /// Defaults to ``NavigationBackSource/systemOrGesture`` so that direct mutations of ``path``
    /// (system back button, swipe-to-go-back) are classified correctly. Navi's programmatic
    /// operations set ``NavigationBackSource/programmatic`` before mutating and always reset it
    /// afterwards.
    var currentSource: NavigationBackSource = .systemOrGesture

    /// Attributes the next path reduction to ``NavigationBackSource/programmatic``.
    ///
    /// Skipped when already set so that repeated calls do not invalidate observers holding
    /// this value.
    mutating func markProgrammaticMutation() {
        guard currentSource != .programmatic else { return }
        currentSource = .programmatic
    }

    /// Restores the resting source so later direct path mutations are classified as
    /// ``NavigationBackSource/systemOrGesture``.
    mutating func resetMutationSource() {
        guard currentSource != .systemOrGesture else { return }
        currentSource = .systemOrGesture
    }

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

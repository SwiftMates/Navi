//
//  NaviCoordinator.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import SwiftUI

@MainActor
/// A main-actor-bound navigation controller protocol for managing a SwiftUI `NavigationPath`.
///
/// Conforming types own navigation state through ``properties`` and can perform stack-based
/// navigation operations such as push, pop, and deep linking.
public protocol NaviController: AnyObject {

    /// Mutable storage for navigation path and controller internals.
    var properties: NaviControllerProperties { get set }

    // MARK: Navigation

    /// Pushes a destination onto the current navigation stack.
    ///
    /// - Parameter destination: The destination to append to the navigation path.
    func push(to destination: any DestinationRepresentable)

    /// Removes the top-most destination from the navigation stack, if available.
    func pop()

    /// Clears the navigation stack and returns to the root destination.
    func popToRoot()

    /// Pops the navigation stack back to the destination marked by the provided origin.
    ///
    /// - Parameter origin: The origin whose ``OriginRepresentable/key`` identifies a previously
    ///   tracked navigation position in the stack.
    func pop(to origin: any OriginRepresentable)

    // MARK: Deeplinking

    /// Resets the stack to root, then pushes each destination from the provided path.
    ///
    /// - Parameter newPath: The destination sequence to apply as a deep-link route.
    func deepLink(to newPath: [any DestinationRepresentable])
}

// MARK: - Default implementation

@MainActor
extension NaviController {

    // MARK: - Public methods

    /// Pushes a destination onto the current navigation stack.
    ///
    /// If the destination defines a navigation origin, the origin is tracked for keyed pop operations.
    ///
    /// - Parameter destination: The destination to append to the navigation path.
    public func push(to destination: any DestinationRepresentable) {
        properties.path.append(destination)
        properties.logger?.logInfo("Path appended with destination: \(destination).")
        if let origin = destination.navigationOrigin {
            properties.naviStackOrigins[origin.key] = properties.path.count
            properties.logger?.logInfo(
                "Navigation origin \(origin) registered as pop target at path index \(properties.path.count)."
            )
        }
    }

    /// Removes the top-most destination from the stack when the path is not empty.
    public func pop() {
        if properties.path.isEmpty == false {
            properties.path.removeLast()
            properties.logger?.logInfo("Last path element removed.")
            syncStackOrigins()
        } else {
            properties.logger?.logError("Attempted to pop but navigation path is already empty.")
        }
    }

    /// Clears all pushed destinations and resets tracked navigation origins.
    public func popToRoot() {
        properties.path = NavigationPath()
        syncStackOrigins(removeAll: true)
        properties.logger?.logInfo("Navigation path cleared.")
    }

    /// Pops the stack back to the destination associated with the given origin.
    ///
    /// Looks up the stored path index for the origin's ``OriginRepresentable/key`` and removes
    /// all destinations pushed after it. If the key cannot be found, an error is logged and an
    /// assertion is triggered in debug builds.
    ///
    /// - Parameter origin: The origin whose ``OriginRepresentable/key`` identifies the pop target.
    public func pop(to origin: any OriginRepresentable) {
        guard let originIndex = properties.naviStackOrigins[origin.key] else {
            properties.logger?.logError(
                "Navigation origin was not found ---> \(String(describing: origin)).")
            assertionFailure("Navigation origin was not found ---> \(origin).")
            return
        }
        let indexToRemove = properties.path.count - originIndex
        properties.logger?.logInfo(
            "Popping \(indexToRemove) destination(s) back to origin: \(origin).")
        pop(last: indexToRemove)
    }

    // MARK: - Deep-link

    /// Replaces the current stack with a deep-link path.
    ///
    /// This operation first resets to root and then pushes each destination in order.
    ///
    /// - Parameter newPath: Ordered destinations representing the desired route.
    public func deepLink(to newPath: [any DestinationRepresentable]) {
        popToRoot()
        for destination in newPath {
            push(to: destination)
        }
        properties.logger?.logInfo("Deep-link path set to: \(newPath).")
    }

    // MARK: - Private methods

    /// Removes tracked navigation origins that no longer correspond to a valid path index.
    ///
    /// Called after mutations to ``NaviControllerProperties/path`` to keep
    /// ``NaviControllerProperties/naviStackOrigins`` in sync with the current stack state.
    ///
    /// - Parameter removeAll: When `true`, clears all tracked origins regardless of index.
    ///   When `false` (the default), removes only those origins whose stored index exceeds
    ///   the current path count.
    private func syncStackOrigins(removeAll: Bool = false) {
        if removeAll {
            properties.naviStackOrigins.removeAll()
            properties.logger?.logInfo("All navigation origins cleared.")
        } else {
            for (key, index) in properties.naviStackOrigins where index > properties.path.count {
                properties.naviStackOrigins.removeValue(forKey: key)
                properties.logger?.logInfo(
                    "Navigation origin removed: \(String(describing: key.debugName)) from index: \(index)."
                )
            }
        }
    }

    /// Removes the specified number of destinations from the end of the navigation stack.
    ///
    /// After removal, tracked navigation origins are synchronized so that any origins pointing
    /// beyond the new path length are discarded. If the requested count exceeds the current
    /// path length, the operation is aborted and an error is logged.
    ///
    /// - Parameter indexCount: The number of trailing destinations to remove from the path.
    private func pop(last indexCount: Int) {
        guard indexCount <= properties.path.count else {
            properties.logger?.logError(
                "Cannot remove more element from the path than what it has ---> \(indexCount) is bigger than \(self.properties.path.count)."
            )
            assertionFailure("Cannot remove more elements than the path contains.")
            return
        }
        properties.path.removeLast(indexCount)
        syncStackOrigins()
    }
}

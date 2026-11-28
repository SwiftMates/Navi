//
//  NaviController.swift
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
    func push<D:  DestinationRepresentable>(to destination: D)

    /// Removes the top-most destination from the navigation stack, if available.
    func pop()

    /// Clears the navigation stack and returns to the root destination.
    func popToRoot()

    /// Pops the navigation stack back to the destination marked by the provided origin.
    ///
    /// - Parameter origin: The origin whose ``OriginRepresentable/key`` identifies a previously
    ///   tracked navigation position in the stack.
    func pop<O: OriginRepresentable>(to origin: O)

    // MARK: Deeplinking

    /// Resets the stack to root, then pushes each destination from the provided path.
    ///
    /// - Parameter newPath: The destination sequence to apply as a deep-link route.
    func deepLink(to newPath: [any DestinationRepresentable])

    // MARK: Back navigation

    /// Called after destinations are removed from the navigation path.
    ///
    /// Invoked for programmatic pops and for system-driven backs (back button or
    /// swipe-to-go-back). The call happens synchronously, inside the path mutation, after
    /// tracked origins have been reconciled.
    ///
    /// Default implementations do nothing; override to react to back navigation.
    ///
    /// - Important: Do not read from or write to ``properties`` in this method.
    ///   The callback runs inside the write access to `properties`, so any re-entrant access
    ///   traps with a Swift exclusivity violation rather than merely misbehaving. Work from the
    ///   passed values and from state stored outside `properties`.
    ///
    /// - Parameters:
    ///   - removedCount: Number of destinations removed by this change.
    ///   - newCount: ``NaviControllerProperties/path`` count after the change.
    ///   - source: Whether the change was programmatic or user initiated.
    func didNavigateBack(
        removedCount: Int,
        newCount: Int,
        source: NavigationBackSource
    )
}

// MARK: - Default implementation

@MainActor
public extension NaviController {

    // MARK: - Public methods

    /// Pushes a destination onto the current navigation stack.
    ///
    /// If the destination defines a navigation origin, the origin is tracked for keyed pop operations.
    ///
    /// - Parameter destination: The destination to append to the navigation path.
    func push<D:  DestinationRepresentable>(to destination: D) {
        properties.path.append(destination)
        properties.logger?.logInfo("Path appended with destination: \(destination).")
        if let origin = destination.navigationOrigin {
            properties.naviStackOrigins[origin.key] = properties.path.count
            properties.logger?.logInfo("Navigation origin \(origin) registered as pop target at path index \(properties.path.count).")
        }
    }

    /// Removes the top-most destination from the stack when the path is not empty.
    func pop() {
        if properties.path.isEmpty == false {
            properties.markProgrammaticMutation()
            defer { properties.resetMutationSource() }
            properties.path.removeLast()
            properties.logger?.logInfo("Last path element removed.")
        } else {
            properties.logger?.logError("Attempted to pop but navigation path is already empty.")
        }
    }

    /// Clears all pushed destinations and resets tracked navigation origins.
    func popToRoot() {
        properties.markProgrammaticMutation()
        defer { properties.resetMutationSource() }
        properties.path = NavigationPath()
        properties.logger?.logInfo("Navigation path cleared.")
    }

    /// Pops the stack back to the destination associated with the given origin.
    ///
    /// Looks up the stored path index for the origin's ``OriginRepresentable/key`` and removes
    /// all destinations pushed after it. If the key cannot be found, an error is logged and an
    /// assertion is triggered in debug builds.
    ///
    /// - Parameter origin: The origin whose ``OriginRepresentable/key`` identifies the pop target.
    func pop<O: OriginRepresentable>(to origin: O) {
        guard let originIndex = properties.naviStackOrigins[origin.key] else {
            properties.logger?.logError("Navigation origin was not found ---> \(String(describing: origin)).")
            assertionFailure("Navigation origin was not found ---> \(origin).")
            return
        }
        let indexToRemove = properties.path.count - originIndex
        properties.markProgrammaticMutation()
        defer { properties.resetMutationSource() }
        properties.logger?.logInfo("Popping \(indexToRemove) destination(s) back to origin: \(origin).")
        pop(last: indexToRemove)
    }

    // MARK: - Back navigation

    /// Default implementation: no-op. Conformers override to react to back navigation.
    func didNavigateBack(
        removedCount: Int,
        newCount: Int,
        source: NavigationBackSource
    ) {}

    /// Installs the bridge that forwards path reductions to ``didNavigateBack(removedCount:newCount:source:)``.
    ///
    /// Call once, after ``properties`` is initialized — typically at the end of `init`.
    /// Calling it again only replaces the existing bridge. The bridge holds the controller
    /// weakly, so no retain cycle is created.
    ///
    /// - Important: The bridge is stored inside ``properties``. Replacing that value
    ///   (for example `properties = NaviControllerProperties()`) removes it, and this method
    ///   has to be called again.
    func enableBackNotifications() {
        properties.onPathDidShrink = { [weak self] removedCount, newCount, source in
            self?.didNavigateBack(
                removedCount: removedCount,
                newCount: newCount,
                source: source
            )
        }
    }

    // MARK: - Deep-link

    /// Replaces the current stack with a deep-link path.
    ///
    /// This operation first resets to root and then pushes each destination in order.
    ///
    /// - Parameter newPath: Ordered destinations representing the desired route.
    func deepLink(to newPath: [any DestinationRepresentable]) {
        popToRoot()
        newPath.forEach { push(to: $0) }
        properties.logger?.logInfo("Deep-link path set to: \(newPath).")
    }

    // MARK: - Private methods

    /// Removes the specified number of destinations from the end of the navigation stack.
    ///
    /// If the requested count exceeds the current path length, the operation is aborted and an error is logged.
    ///
    /// - Parameter indexCount: The number of trailing destinations to remove from the path.
    private func pop(last indexCount: Int) {
        guard indexCount <= properties.path.count else {
            properties.logger?.logError("Cannot remove more element from the path than what it has ---> \(indexCount) is bigger than \(self.properties.path.count).")
            assertionFailure("Cannot remove more elements than the path contains.")
            return
        }
        properties.path.removeLast(indexCount)
    }
}

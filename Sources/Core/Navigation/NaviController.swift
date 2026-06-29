//
//  NaviCoordinator.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import SwiftUI
import OSLog

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

    /// Pops the navigation stack back to the destination marked by the provided origin key.
    ///
    /// - Parameter destinationKey: The key associated with a previously tracked navigation origin.
    func pop(to destinationKey: NavigationOriginKey)

    // MARK: Deeplinking

    /// Resets the stack to root, then pushes each destination from the provided path.
    ///
    /// - Parameter newPath: The destination sequence to apply as a deep-link route.
    func deepLink(to newPath: [any DestinationRepresentable])
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
    func push(to destination: any DestinationRepresentable) {
        properties.path.append(destination)
        if let key = destination.navigationOrigin {
            properties.naviStackOrigins[key] = properties.path.count
        }
    }

    /// Removes the top-most destination from the stack when the path is not empty.
    func pop() {
        if properties.path.isEmpty == false {
            properties.path.removeLast()
            syncStackOrigins()
        }
    }

    /// Clears all pushed destinations and resets tracked navigation origins.
    func popToRoot() {
        properties.path = NavigationPath()
        syncStackOrigins(removeAll: true)
    }

    /// Pops the stack back to the destination associated with the given origin key.
    ///
    /// If the key cannot be found, a fault is logged and an assertion is triggered in debug builds.
    ///
    /// - Parameter destinationKey: The origin key used to identify the pop target.
    func pop(to destinationKey: NavigationOriginKey) {
        guard let originIndex = properties.naviStackOrigins[destinationKey] else {
            properties.naviLogger.fault("Navi origin key was not found ---> \(String(describing: destinationKey))")
            assertionFailure("Navi origin key was not found ---> \(destinationKey)")
            return
        }

        let indexToRemove = properties.path.count - originIndex
        pop(last: indexToRemove)
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
    }

    // MARK: - Private methods

    private func syncStackOrigins(removeAll: Bool = false) {
        if removeAll {
            properties.naviStackOrigins.removeAll()
        } else {
            for (key, index) in properties.naviStackOrigins where index > properties.path.count {
                properties.naviStackOrigins.removeValue(forKey: key)
            }
        }
    }
    
    private func pop(last indexCount: Int) {
        guard indexCount <= properties.path.count else {
            properties.naviLogger.fault("Cannot remove more element from the path than what it has ---> \(indexCount) is bigger than \(self.properties.path.count)")
            return
        }
        properties.path.removeLast(indexCount)
        syncStackOrigins()
    }
}

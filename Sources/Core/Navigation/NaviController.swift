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
    func push<D: DestinationRepresentable>(to destination: D)

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
    func push<D: DestinationRepresentable>(to destination: D) {
        properties.path.append(destination)
        
        if let origin = destination.navigationOrigin {
            properties.naviStackOrigins[origin.key] = properties.path.count
        }

        logInfo(
            destination: destination,
            origin: destination.navigationOrigin,
            message: "Path appended with the new destination (and origin) successfully.",
            pathCount: properties.path.count
        )
    }

    /// Removes the top-most destination from the stack when the path is not empty.
    func pop() {
        if properties.path.isEmpty == false {
            properties.path.removeLast()
            syncStackOrigins()
            
            logInfo(
                message: "Last path element removed.",
                pathCount: properties.path.count
            )
        }
    }

    /// Clears all pushed destinations and resets tracked navigation origins.
    func popToRoot() {
        properties.path = NavigationPath()
        syncStackOrigins(removeAll: true)

        logInfo(
            message: "Navigation path cleared.",
            pathCount: properties.path.count
        )
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
            logError(
                origin: origin,
                message: "Navigation origin was not found.",
                pathCount: properties.path.count
            )
            
            assertionFailure("Navigation origin was not found ---> \(origin).")
            return
        }
        let indexToRemove = properties.path.count - originIndex
        
        logInfo(
            origin: origin,
            message: "Popping back to origin.",
            pathCount: properties.path.count
        )
        
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

        logInfo(
            message: "Deep-link path set to new path.",
            pathCount: properties.path.count
        )
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
            
            logInfo(
                message: "All navigation origins cleared.",
                pathCount: properties.path.count
            )
        } else {
            for (key, index) in properties.naviStackOrigins where index > properties.path.count {
                properties.naviStackOrigins.removeValue(forKey: key)
                
                logInfo(
                    message: "Navigation origin removed.",
                    pathCount: properties.path.count
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
            logError(
                message: "Cannot remove more element from the path than what it has",
                pathCount: properties.path.count
            )
            assertionFailure("Cannot remove more elements than the path contains.")
            return
        }
        properties.path.removeLast(indexCount)
        syncStackOrigins()
    }
    
    // MARK: Helpers
    
    private func logInfo(
        destination: (any DestinationRepresentable)? = nil,
        origin: (any OriginRepresentable)? = nil,
        message: String,
        pathCount: Int
    ) {
        let loggingRawData = NaviLoggingInfoModel.RawData(
            destination: destination,
            origin: origin,
            pathCount: pathCount
        )
        let loggingInfoModel = NaviLoggingInfoModel(
            message: message,
            rawData: loggingRawData
        )
        
        properties.logger?.logInfo(loggingInfoModel)
    }
    
    private func logError(
        destination: (any DestinationRepresentable)? = nil,
        origin: (any OriginRepresentable)? = nil,
        message: String,
        pathCount: Int
    ) {
        let loggingRawData = NaviLoggingInfoModel.RawData(
            destination: destination,
            origin: origin,
            pathCount: pathCount
        )
        let loggingInfoModel = NaviLoggingInfoModel(
            message: message,
            rawData: loggingRawData
        )
        
        properties.logger?.logError(loggingInfoModel)
    }
}

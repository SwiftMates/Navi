//
//  NaviCoordinator.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import SwiftUI
import OSLog

@MainActor
public protocol NaviCoordinator: AnyObject {

    var properties: NaviCoordinatorProperties { get set }

    // MARK: Navigation

    func push(to destination: any Navigable)
    func pop()
    func pop(to destinationKey: NaviStackOriginKeys)
    func popToRoot()

    // MARK: Deeplinking

    func deeplink(to newPath: [any Navigable])
}

// MARK: - Default implementation

@MainActor
public extension NaviCoordinator {

    // MARK: - Public methods

    func push(to destination: any Navigable) {
        properties.path.append(destination)
        if let key = destination.navigationOrigin {
            properties.naviStackOrigins[key] = properties.path.count
        }
    }

    func pop() {
        if properties.path.isEmpty == false {
            properties.path.removeLast()
            syncStackOrigins()
        }
    }

    func popToRoot() {
        properties.path = NavigationPath()
        syncStackOrigins(removeAll: true)
    }

    func pop(to destinationKey: NaviStackOriginKeys) {
        guard let originIndex = properties.naviStackOrigins[destinationKey] else {
            properties.naviLogger.fault("Navi origin key was not found ---> \(String(describing: destinationKey))")
            assertionFailure("Navi origin key was not found ---> \(destinationKey)")
            return
        }

        let indexToRemove = properties.path.count - originIndex
        properties.path.removeLast(indexToRemove)
        syncStackOrigins()
    }

    // MARK: - Deep-link

    func deeplink(to newPath: [any Navigable]) {
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
}

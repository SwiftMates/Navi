//
//  NaviCoordinator.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import SwiftUI
import OSLog

@MainActor
public protocol NaviController: AnyObject {

    var properties: NaviControllerProperties { get set }

    // MARK: Navigation

    func push(to destination: any DestinationRepresentable)
    func pop()
    func popToRoot()
    func pop(to destinationKey: NavigationOriginKey)

    // MARK: Deeplinking

    func deepLink(to newPath: [any DestinationRepresentable])
}

// MARK: - Default implementation

@MainActor
public extension NaviController {

    // MARK: - Public methods

    func push(to destination: any DestinationRepresentable) {
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

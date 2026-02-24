//
//  Navigable.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import Foundation

public protocol DestinationRepresentable: Hashable {
    var navigationOrigin: NavigationOriginKeys? { get }
}

// MARK: - Default Implementation

public extension DestinationRepresentable {
    var navigationOrigin: NavigationOriginKeys? { nil }
}

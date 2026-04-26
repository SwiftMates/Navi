//
//  Navigable.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import Foundation

public protocol DestinationRepresentable: Hashable {
    var navigationOrigin: NavigationOriginKey? { get }
}

// MARK: - Default Implementation

public extension DestinationRepresentable {
    var navigationOrigin: NavigationOriginKey? { nil }
}

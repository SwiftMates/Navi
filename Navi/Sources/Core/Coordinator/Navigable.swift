//
//  Navigable.swift
//  Navi
//
//  Created by David Pall on 2026. 01. 15..
//

import Foundation

public protocol Navigable: Hashable {
    var navigationOrigin: NaviStackOriginKeys? { get }
}

// MARK: - Default Implementation

public extension Navigable {
    var navigationOrigin: NaviStackOriginKeys? { nil }
}

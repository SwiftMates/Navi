//
//  DeeplinkManager.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import Foundation
import Navi


protocol DeeplinkManagerProtocol {
    func handle(_ deeplink: Deeplink) -> [any DestinationRepresentable]
}

final class DeeplinkManager: DeeplinkManagerProtocol {
    func handle(_ deeplink: Deeplink) -> [any DestinationRepresentable] {
        switch deeplink {
        case .homeTab(let homeTabDeeplink):
            return HomeTabDeeplinkBuilder().build(for: homeTabDeeplink)
        case .deeplinkTab(let deeplinkTabDeeplink):
            return [] // TODO: - Forward to builder
        }
    }
}

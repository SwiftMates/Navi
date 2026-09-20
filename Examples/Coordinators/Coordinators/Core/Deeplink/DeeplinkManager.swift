//
//  DeeplinkManager.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import Foundation
import Navi

struct DeeplinkManager {
    func handle(_ deeplink: Deeplink) async -> [any DestinationRepresentable] {
        switch deeplink {
        case .homeTab(let homeTabDeeplink):
            return await HomeTabDeeplinkBuilder().build(for: homeTabDeeplink)
        case .deeplinkTab(let deeplinkTabDeeplink):
            return await DeeplinksTabDeeplinkBuilder().build(for: deeplinkTabDeeplink)
        }
    }
}

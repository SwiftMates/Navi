//
//  DeeplinkPublisher.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import Combine

protocol DeeplinkPublisherProtocol {
    var publisher: AnyPublisher<Deeplink, Never> { get }
    
    func go(to deeplink: Deeplink)
}

final class DeeplinkPublisher: DeeplinkPublisherProtocol {
    
    // MARK: - Private properties
    
    private var deepLinkPublisher = PassthroughSubject<Deeplink, Never>()
    
    // MARK: - Public properties
    
    /// Publishes the `DeepLink` when the Manager's `go(to deepLink: DeepLink)` function is called
    var publisher: AnyPublisher<Deeplink, Never> {
        deepLinkPublisher.eraseToAnyPublisher()
    }
    
    /// Publishes the `DeepLink` for the Manager's subscribers
    /// - Parameter deepLink: Defines the Tab and the specific destination inside it
    func go(to deeplink: Deeplink) {
        deepLinkPublisher.send(deeplink)
    }
}

// Global property for demo simplicity, ideally use a dependency injection tool
let deeplinkPublisher = DeeplinkPublisher()

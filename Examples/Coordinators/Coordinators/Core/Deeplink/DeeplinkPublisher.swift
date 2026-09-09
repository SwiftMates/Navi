//
//  DeeplinkPublisher.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

protocol DeeplinkPublisherProtocol {
    var stream: AsyncStream<Deeplink> { get }
    
    func go(to deeplink: Deeplink)
}

final class DeeplinkPublisher: DeeplinkPublisherProtocol {
    
    // MARK: - Private properties
    
    private let continuation: AsyncStream<Deeplink>.Continuation
    
    // MARK: - Public properties
    
    let stream: AsyncStream<Deeplink>
    
    // MARK: - Lifecycle
    
    init() {
        let (stream, continuation) = AsyncStream.makeStream(of: Deeplink.self)
        self.stream = stream
        self.continuation = continuation
    }
    
    /// Publishes the `DeepLink` for the Manager's subscriber
    /// - Parameter deepLink: Defines the Tab and the specific destination inside it
    func go(to deeplink: Deeplink) {
        continuation.yield(deeplink)
    }
}

// Global property for demo simplicity, ideally use a dependency injection tool
let deeplinkPublisher = DeeplinkPublisher()

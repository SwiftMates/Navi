//
//  NavigationBackNotificationTests.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 11/11/2026.
//

import Testing
import SwiftUI
@testable import Navi

// MARK: - Unit tests suite

@Suite("NaviController Back Notification")
@MainActor
struct NavigationBackNotificationTests {

    // MARK: - Nested types

    enum TestDestination: DestinationRepresentable {
        case screenA
        case screenB
        case screenC(randomData: String)

        var navigationOrigin: (any OriginRepresentable)? {
            switch self {
            case .screenB: return Origins.screenB
            case .screenC: return Origins.screenC
            case .screenA: return nil
            }
        }

        enum Origins: OriginRepresentable {
            case screenB
            case screenC

            var key: NavigationOriginKey {
                switch self {
                case .screenB: Self.screenBOriginKey
                case .screenC: Self.screenCOriginKey
                }
            }

            static let screenBOriginKey = NavigationOriginKey(debugName: "screenB")
            static let screenCOriginKey = NavigationOriginKey(debugName: "screenC")
        }
    }

    final class RecordingController: NaviController {
        var properties: NaviControllerProperties

        private(set) var recorded: [(removedCount: Int, newCount: Int, source: NavigationBackSource)] = []

        init(enableNotifications: Bool = true) {
            properties = NaviControllerProperties()
            if enableNotifications {
                enableBackNotifications()
            }
        }

        func didNavigateBack(
            removedCount: Int,
            newCount: Int,
            source: NavigationBackSource
        ) {
            // Note: `properties` must not be touched here. The callback runs inside the
            // write access to it, so any read or write traps with an exclusivity violation.
            recorded.append((removedCount, newCount, source))
        }
    }

    // MARK: - Programmatic back

    @Test
    func `pop should notify with one removed destination when path is not empty`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)

        controller.pop()

        #expect(controller.recorded.count == 1)
        #expect(controller.recorded.first?.removedCount == 1)
        #expect(controller.recorded.first?.newCount == 1)
        #expect(controller.recorded.first?.source == .programmatic)
    }

    @Test
    func `popToRoot should notify with the whole stack size when path has destinations`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))

        controller.popToRoot()

        #expect(controller.recorded.count == 1)
        #expect(controller.recorded.first?.removedCount == 3)
        #expect(controller.recorded.first?.newCount == 0)
        #expect(controller.recorded.first?.source == .programmatic)
    }

    @Test
    func `pop to origin should notify with the number of removed levels`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))

        controller.pop(to: TestDestination.Origins.screenB)

        #expect(controller.recorded.count == 1)
        #expect(controller.recorded.first?.removedCount == 1)
        #expect(controller.recorded.first?.newCount == 2)
        #expect(controller.recorded.first?.source == .programmatic)
    }

    @Test
    func `pop to topmost origin should not notify`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))

        controller.pop(to: TestDestination.Origins.screenC)

        #expect(controller.recorded.isEmpty)
    }

    @Test
    func `deepLink should notify only for the root reset`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)

        controller.deepLink(to: [TestDestination.screenC(randomData: "testData")])

        #expect(controller.recorded.count == 1)
        #expect(controller.recorded.first?.removedCount == 2)
        #expect(controller.recorded.first?.newCount == 0)
        #expect(controller.recorded.first?.source == .programmatic)
    }

    // MARK: - System / gesture back

    @Test
    func `direct path removal should notify as system or gesture`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)

        // Simulate a swipe-back / system back button: SwiftUI mutates the bound
        // NavigationPath directly, bypassing pop().
        controller.properties.path.removeLast()

        #expect(controller.recorded.count == 1)
        #expect(controller.recorded.first?.removedCount == 1)
        #expect(controller.recorded.first?.newCount == 1)
        #expect(controller.recorded.first?.source == .systemOrGesture)
    }

    @Test
    func `direct path replacement should notify as system or gesture with the whole stack size`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)

        // Simulate SwiftUI writing an empty path through the binding.
        controller.properties.path = NavigationPath()

        #expect(controller.recorded.count == 1)
        #expect(controller.recorded.first?.removedCount == 2)
        #expect(controller.recorded.first?.newCount == 0)
        #expect(controller.recorded.first?.source == .systemOrGesture)
    }

    // MARK: - Suppressed notifications

    @Test
    func `push should not notify`() {
        let controller = RecordingController()

        controller.push(to: TestDestination.screenA)

        #expect(controller.recorded.isEmpty)
    }

    @Test
    func `pop should not notify when path is empty`() {
        let controller = RecordingController()

        controller.pop()

        #expect(controller.recorded.isEmpty)
    }

    @Test
    func `popToRoot should not notify when path is empty`() {
        let controller = RecordingController()

        controller.popToRoot()

        #expect(controller.recorded.isEmpty)
    }

    @Test
    func `controller should not notify when back notifications were not enabled`() {
        let controller = RecordingController(enableNotifications: false)
        controller.push(to: TestDestination.screenA)

        controller.pop()

        #expect(controller.recorded.isEmpty)
        #expect(controller.properties.path.isEmpty)
    }

    @Test
    func `controller should not notify when properties are replaced after enabling`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)

        controller.properties = NaviControllerProperties()
        controller.push(to: TestDestination.screenB)
        controller.pop()

        #expect(controller.recorded.isEmpty)
    }

    // MARK: - Source tracking

    @Test
    func `pop on empty path should not leak programmatic source into the next system back`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)

        controller.pop()
        // Path is empty now: this call cannot reduce it, so it must not leave the source set.
        controller.pop()
        #expect(controller.recorded.count == 1)

        controller.push(to: TestDestination.screenB)
        controller.properties.path.removeLast()

        #expect(controller.recorded.count == 2)
        #expect(controller.recorded.last?.source == .systemOrGesture)
    }

    @Test
    func `popToRoot on empty path should not leak programmatic source into the next system back`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)

        controller.popToRoot()
        controller.popToRoot()
        #expect(controller.recorded.count == 1)

        controller.push(to: TestDestination.screenB)
        controller.properties.path.removeLast()

        #expect(controller.recorded.count == 2)
        #expect(controller.recorded.last?.source == .systemOrGesture)
    }

    @Test
    func `consecutive programmatic pops should each report the programmatic source`() {
        let controller = RecordingController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))

        controller.pop()
        controller.pop()

        #expect(controller.recorded.count == 2)
        #expect(controller.recorded.map(\.source) == [.programmatic, .programmatic])
        #expect(controller.recorded.map(\.newCount) == [2, 1])
    }

    // MARK: - Bridge installation

    @Test
    func `enabling back notifications twice should still notify once per mutation`() {
        let controller = RecordingController()
        controller.enableBackNotifications()
        controller.push(to: TestDestination.screenA)

        controller.pop()

        #expect(controller.recorded.count == 1)
    }

    @Test
    func `released controller should not be notified when a copy of its properties mutates`() throws {
        var controller: RecordingController? = RecordingController()
        controller?.push(to: TestDestination.screenA)

        // The bridge travels with the struct copy but holds the controller weakly.
        var copiedProperties = try #require(controller?.properties)
        let probe = WeakBox(controller)

        controller = nil

        #expect(probe.value == nil)

        copiedProperties.path.removeLast()

        #expect(copiedProperties.path.isEmpty)
    }
}

// MARK: - Test doubles

private final class WeakBox<Value: AnyObject> {
    weak var value: Value?

    init(_ value: Value?) {
        self.value = value
    }
}

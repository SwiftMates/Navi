//
//  NaviControllerTests.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 26/04/2026.
//


import Testing
import Foundation
@testable import Navi

// MARK: - Unit tests suite
@Suite("NaviController Navigation Operations")
@MainActor
struct NaviControllerTests {
    // MARK: - Nested types

    enum TestDestination: DestinationRepresentable {
        case screenA
        case screenB
        case screenC
        case screenD

        var navigationOrigin: (any OriginRepresentable)? {
            switch self {
            case .screenB: return TestOrigin.screenB
            case .screenC: return TestOrigin.screenC
            default: return nil
            }
        }
    }

    struct TestDestinationWithOrigin: DestinationRepresentable {
        let id: String
        let navigationOrigin: (any OriginRepresentable)?

        static func == (lhs: TestDestinationWithOrigin, rhs: TestDestinationWithOrigin) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    struct TestOrigin: OriginRepresentable {
        let key: NavigationOriginKey
        let debugName: String

        static let screenB = TestOrigin(key: .screenB, debugName: "screenB")
        static let screenC = TestOrigin(key: .screenC, debugName: "screenC")
        static let alternateScreenB = TestOrigin(key: .screenB, debugName: "alternateScreenB")
    }

    @Test
    func `push should add destinations and set stack origins when destinations are pushed`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[.screenB] == 1)
    }

    @Test
    func `pop should remove the last destination and keep remaining origins when stack is not empty`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.pop()
        #expect(controller.properties.path.count == 1)
        #expect(controller.properties.naviStackOrigins[.screenB] == 1)
    }

    @Test
    func `popToRoot should clear path and origins when stack has destinations`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.popToRoot()
        #expect(controller.properties.path.count == 0)
        #expect(controller.properties.naviStackOrigins.isEmpty)
    }

    @Test
    func `pop should navigate back to origin key destination when origin exists in stack`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.pop(to: TestOrigin.screenB)
        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[.screenB] == 2)
        #expect(controller.properties.naviStackOrigins[.screenC] == nil)
    }

    @Test
    func `push should track navigation origin by origin key`() {
        let controller: TestNaviController = TestNaviController()
        let destination = TestDestinationWithOrigin(
            id: "custom-screen",
            navigationOrigin: TestOrigin.alternateScreenB
        )

        controller.push(to: destination)

        #expect(controller.properties.path.count == 1)
        #expect(controller.properties.naviStackOrigins[.screenB] == 1)
        #expect(controller.properties.naviStackOrigins[.screenC] == nil)
    }

    @Test
    func `pop should accept different origin value with same key as stored origin`() {
        let controller: TestNaviController = TestNaviController()
        let destination = TestDestinationWithOrigin(
            id: "custom-screen",
            navigationOrigin: TestOrigin.screenB
        )

        controller.push(to: TestDestination.screenA)
        controller.push(to: destination)
        controller.push(to: TestDestination.screenC)
        controller.pop(to: TestOrigin.alternateScreenB)

        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[.screenB] == 2)
        #expect(controller.properties.naviStackOrigins[.screenC] == nil)
    }

    @Test
    func `deepLink should replace path with new sequence and update origins when new path is provided`() {
        let controller: TestNaviController = TestNaviController()
        let newPath: [any DestinationRepresentable] = [
            TestDestination.screenA,
            TestDestination.screenB,
            TestDestination.screenB
        ]
        controller.push(to: TestDestination.screenC)
        controller.deepLink(to: newPath)
        #expect(controller.properties.path.count == 3)
        #expect(controller.properties.naviStackOrigins[.screenB] == 3)
    }

    @Test
    func `pop should do nothing when path is empty`() {
        let controller: TestNaviController = TestNaviController()
        controller.pop()
        #expect(controller.properties.path.count == 0)
        #expect(controller.properties.naviStackOrigins.isEmpty)
    }

    @Test
    func `pop should prune removed origin metadata when popping destination with origin`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.pop()
        #expect(controller.properties.path.count == 1)
        #expect(controller.properties.naviStackOrigins[.screenB] == 1)
        #expect(controller.properties.naviStackOrigins[.screenC] == nil)
    }

    @Test
    func `pop should not modify stack when target origin is already topmost`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.pop(to: TestOrigin.screenC)
        #expect(controller.properties.path.count == 3)
        #expect(controller.properties.naviStackOrigins[.screenB] == 2)
        #expect(controller.properties.naviStackOrigins[.screenC] == 3)
    }

    @Test
    func `push should update existing origin index when same origin appears again`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        #expect(controller.properties.path.count == 3)
        #expect(controller.properties.naviStackOrigins[.screenB] == 3)
    }

    @Test
    func `deepLink should clear path and origins when new path is empty`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.deepLink(to: [])
        #expect(controller.properties.path.count == 0)
        #expect(controller.properties.naviStackOrigins.isEmpty)
    }

    @Test
    func `deepLink should replace existing state and keep only new path origins when new path is provided`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenC)
        controller.push(to: TestDestination.screenA)

        let newPath: [any DestinationRepresentable] = [
            TestDestination.screenA,
            TestDestination.screenB
        ]

        controller.deepLink(to: newPath)

        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[.screenB] == 2)
        #expect(controller.properties.naviStackOrigins[.screenC] == nil)
    }

    @Test
    func `push should log appended destination when destination has no navigation origin`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenA)

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with destination: screenA."
        ])
        #expect(controller.logger.logInfoCallsCount == 1)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `push should log appended destination and origin when destination has navigation origin`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with destination: screenB.",
            "Navigation origin '\(NavigationOriginKey.screenB)' set to path index: 1 with destination: screenB."
        ])
        #expect(controller.logger.logInfoCallsCount == 2)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `pop should log last path element removed when stack is not empty`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenA)
        controller.pop()

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with destination: screenA.",
            "Last path element removed."
        ])
        #expect(controller.logger.logInfoCallsCount == 2)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `pop should log removed origin when popped destination has navigation origin`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.pop()

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with destination: screenB.",
            "Navigation origin '\(NavigationOriginKey.screenB)' set to path index: 1 with destination: screenB.",
            "Path appended with destination: screenC.",
            "Navigation origin '\(NavigationOriginKey.screenC)' set to path index: 2 with destination: screenC.",
            "Last path element removed.",
            "Navigation origin removed: \(NavigationOriginKey.screenC) from index: 2."
        ])
        #expect(controller.logger.logInfoCallsCount == 6)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `popToRoot should log origins cleared and path cleared`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)
        controller.popToRoot()

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with destination: screenB.",
            "Navigation origin '\(NavigationOriginKey.screenB)' set to path index: 1 with destination: screenB.",
            "All navigation origins cleared.",
            "Navigation path cleared."
        ])
        #expect(controller.logger.logInfoCallsCount == 4)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `deepLink should log root clearing pushed destinations and final path`() {
        let controller: TestNaviController = TestNaviController()
        let newPath: [any DestinationRepresentable] = [
            TestDestination.screenA,
            TestDestination.screenB
        ]

        controller.deepLink(to: newPath)

        #expect(controller.logger.logInfoReceivedInvocations == [
            "All navigation origins cleared.",
            "Navigation path cleared.",
            "Path appended with destination: screenA.",
            "Path appended with destination: screenB.",
            "Navigation origin '\(NavigationOriginKey.screenB)' set to path index: 2 with destination: screenB.",
            "Deep-link path set to: \(newPath)."
        ])
        #expect(controller.logger.logInfoCallsCount == 6)
        #expect(controller.logger.logErrorCalled == false)
    }
}

// MARK: - Navigation Origin Keys

extension NavigationOriginKey {
    static let screenB = NavigationOriginKey(debugName: "screenB")
    static let screenC = NavigationOriginKey(debugName: "screenC")
}

//
//  NaviControllerTests.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 26/04/2026.
//

import Foundation
import Testing

@testable import Navi

// MARK: - Unit tests suite
@Suite("NaviController Navigation Operations")
@MainActor
struct NaviControllerTests {
    // MARK: - Nested types

    enum TestDestination: DestinationRepresentable {
        case screenA
        case screenB
        case screenC(randomData: String)
        case screenD(randomData: String)

        var navigationOrigin: (any OriginRepresentable)? {
            switch self {
            case .screenB: return Origins.screenB
            case .screenC: return Origins.screenC
            default: return nil
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

    @Test
    func `push should add destinations and set stack origins when destinations are pushed`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        #expect(controller.properties.path.count == 2)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 1)
    }

    @Test
    func
        `pop should remove the last destination and keep remaining origins when stack is not empty`()
    {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.pop()
        #expect(controller.properties.path.count == 1)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 1)
    }

    @Test
    func `popToRoot should clear path and origins when stack has destinations`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.popToRoot()
        #expect(controller.properties.path.count == 0)
        #expect(controller.properties.naviStackOrigins.isEmpty)
    }

    @Test
    func `pop should navigate back to origin key destination when origin exists in stack`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.pop(to: TestDestination.Origins.screenB)
        #expect(controller.properties.path.count == 2)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 2)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenCOriginKey] == nil)
    }

    @Test
    func `push should track navigation origin by origin key`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenD(randomData: "testData"))

        #expect(controller.properties.path.count == 2)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 1)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenCOriginKey] == nil)
    }

    @Test
    func
        `deepLink should replace path with new sequence and update origins when new path is provided`()
    {
        let controller: TestNaviController = TestNaviController()
        let newPath: [any DestinationRepresentable] = [
            TestDestination.screenA,
            TestDestination.screenB,
            TestDestination.screenB,
        ]
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.deepLink(to: newPath)
        #expect(controller.properties.path.count == 3)
        // TODO: - Check screenC is not in origin keys
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 3)
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
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.pop()
        #expect(controller.properties.path.count == 1)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 1)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenCOriginKey] == nil)
    }

    @Test
    func `pop should not modify stack when target origin is already topmost`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.pop(to: TestDestination.Origins.screenC)
        #expect(controller.properties.path.count == 3)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 2)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenCOriginKey] == 3)
    }

    @Test
    func `push should update existing origin index when same origin appears again`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        #expect(controller.properties.path.count == 3)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 3)
    }

    @Test
    func `manually removing last path element does not sync origins`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))

        // Simulate a swipe-back / system back button: SwiftUI mutates the bound
        // NavigationPath directly, bypassing pop() and syncStackOrigins().
        controller.properties.path.removeLast()

        #expect(controller.properties.path.count == 1)
        // origins are NOT reconciled — syncStackOrigins() only runs inside pop().
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenCOriginKey] == 2)
    }

    @Test
    func `push after simulated back navigation updates origin to the latest count`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenC(randomData: "testData"))

        // Simulate two swipe-backs: direct NavigationPath mutation, bypassing pop().
        controller.properties.path.removeLast(2)
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenCOriginKey] == 3)

        // Navigate back to the same screen; it now sits at a shallower depth.
        controller.push(to: TestDestination.screenC(randomData: "moreData"))

        #expect(controller.properties.path.count == 2)
        // Origin updated to the latest count (2), not the stale 3.
        #expect(
            controller.properties.naviStackOrigins[TestDestination.Origins.screenCOriginKey] == 2)
    }

    @Test
    func `deepLink should clear path and origins when new path is empty`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.deepLink(to: [])
        #expect(controller.properties.path.count == 0)
        #expect(controller.properties.naviStackOrigins.isEmpty)
    }

    @Test
    func `deepLink should replace existing state and keep only new path origins when new path is provided`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.push(to: TestDestination.screenA)

        let newPath: [any DestinationRepresentable] = [
            TestDestination.screenA,
            TestDestination.screenB,
        ]

        controller.deepLink(to: newPath)

        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenBOriginKey] == 2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenCOriginKey] == nil)
    }

    @Test
    func `push should log appended destination when destination has no navigation origin`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenA)

        #expect(
            controller.logger.logInfoReceivedInvocations == [
                "Path appended with destination: screenA."
            ])
        #expect(controller.logger.logInfoCallsCount == 1)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `push should log appended destination and origin when destination has navigation origin`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)

        #expect(
            controller.logger.logInfoReceivedInvocations == [
                "Path appended with destination: screenB.",
                "Navigation origin \(TestDestination.Origins.screenB) registered as pop target at path index 1.",
            ])
        #expect(controller.logger.logInfoCallsCount == 2)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `pop should log last path element removed when stack is not empty`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenA)
        controller.pop()

        #expect(
            controller.logger.logInfoReceivedInvocations == [
                "Path appended with destination: screenA.",
                "Last path element removed.",
            ])
        #expect(controller.logger.logInfoCallsCount == 2)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `pop should log removed origin when popped destination has navigation origin`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.pop()

        #expect(
            controller.logger.logInfoReceivedInvocations == [
                "Path appended with destination: screenB.",
                "Navigation origin \(TestDestination.Origins.screenB) registered as pop target at path index 1.",
                "Path appended with destination: screenC(randomData: \"testData\").",
                "Navigation origin \(TestDestination.Origins.screenC) registered as pop target at path index 2.",
                "Last path element removed.",
                "Navigation origin removed: Optional(\"\(TestDestination.Origins.screenC)\") from index: 2.",
            ])
        #expect(controller.logger.logInfoCallsCount == 6)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `popToRoot should log origins cleared and path cleared`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)
        controller.popToRoot()

        #expect(
            controller.logger.logInfoReceivedInvocations == [
                "Path appended with destination: screenB.",
                "Navigation origin \(TestDestination.Origins.screenB) registered as pop target at path index 1.",
                "All navigation origins cleared.",
                "Navigation path cleared.",
            ])
        #expect(controller.logger.logInfoCallsCount == 4)
        #expect(controller.logger.logErrorCalled == false)
    }

    @Test
    func `deepLink should log root clearing pushed destinations and final path`() {
        let controller: TestNaviController = TestNaviController()
        let newPath: [any DestinationRepresentable] = [
            TestDestination.screenA,
            TestDestination.screenB,
        ]

        controller.deepLink(to: newPath)

        #expect(
            controller.logger.logInfoReceivedInvocations == [
                "All navigation origins cleared.",
                "Navigation path cleared.",
                "Path appended with destination: screenA.",
                "Path appended with destination: screenB.",
                "Navigation origin \(TestDestination.Origins.screenB) registered as pop target at path index 2.",
                "Deep-link path set to: \(newPath).",
            ])
        #expect(controller.logger.logInfoCallsCount == 6)
        #expect(controller.logger.logErrorCalled == false)
    }
}

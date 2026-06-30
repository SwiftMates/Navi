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

        var navigationOrigin: NavigationOriginKey? {
            switch self {
            case .screenB: return NavigationOriginKey.screenB
            case .screenC: return NavigationOriginKey.screenC
            default: return nil
            }
        }
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
        controller.pop(to: .screenB)
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
        controller.pop(to: .screenC)
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
}

// MARK: - Navigation Origin Keys

extension NavigationOriginKey {
    static let screenB = NavigationOriginKey(debugName: "screenB")
    static let screenC = NavigationOriginKey(debugName: "screenC")
}

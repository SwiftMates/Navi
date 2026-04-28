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

    @Test("push adds destinations and sets stack origins")
    func testPush()  {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[.screenB] == 1)
    }

    @Test("pop removes the last destination and updates origins")
    func testPop()  {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.pop()
        #expect(controller.properties.path.count == 1)
        #expect(controller.properties.naviStackOrigins[.screenB] == 1)
    }

    @Test("popToRoot clears the path and origins")
    func testPopToRoot()  {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.popToRoot()
        #expect(controller.properties.path.count == 0)
        #expect(controller.properties.naviStackOrigins.isEmpty)
    }

    @Test("pop(to:) navigates back to the origin key destination if present")
    func testPopToOriginKey()  {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.pop(to: .screenB)
        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[.screenB] == 2)
        #expect(controller.properties.naviStackOrigins[.screenC] == nil)
    }

    @Test("deepLink replaces the path with the new sequence of destinations")
    func testDeepLink()  {
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

    @Test("pop on empty path is a no-op")
    func testPopOnEmptyPath()  {
        let controller: TestNaviController = TestNaviController()
        controller.pop()
        #expect(controller.properties.path.count == 0)
        #expect(controller.properties.naviStackOrigins.isEmpty)
    }

    @Test("pop removes origin metadata for destinations removed from path")
    func testPopPrunesRemovedOrigin()  {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.pop()
        #expect(controller.properties.path.count == 1)
        #expect(controller.properties.naviStackOrigins[.screenB] == 1)
        #expect(controller.properties.naviStackOrigins[.screenC] == nil)
    }

    @Test("pop(to:) does not modify the stack when destination is already topmost")
    func testPopToTopmostOriginIsNoOp()  {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.pop(to: .screenC)
        #expect(controller.properties.path.count == 3)
        #expect(controller.properties.naviStackOrigins[.screenB] == 2)
        #expect(controller.properties.naviStackOrigins[.screenC] == 3)
    }

    @Test("push updates origin index when the same origin appears again")
    func testPushUpdatesExistingOriginIndex()  {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        #expect(controller.properties.path.count == 3)
        #expect(controller.properties.naviStackOrigins[.screenB] == 3)
    }

    @Test("deepLink to empty path clears path and origins")
    func testDeepLinkToEmptyPath()  {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC)
        controller.deepLink(to: [])
        #expect(controller.properties.path.count == 0)
        #expect(controller.properties.naviStackOrigins.isEmpty)
    }
}

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

    @DestinationRepresentable
    enum TestDestination {
        case screenA
        @OriginKey case screenB
        @OriginKey case screenC(randomData: String)
        case screenD(randomData: String)
    }
    
    @Test
    func `push should add destinations and set stack origins when destinations are pushed`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 1)
    }

    @Test
    func `pop should remove the last destination and keep remaining origins when stack is not empty`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.pop()
        #expect(controller.properties.path.count == 1)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 1)
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
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenC.key] == nil)
    }

    @Test
    func `push should track navigation origin by origin key`() {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenD(randomData: "testData"))

        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 1)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenC.key] == nil)
    }

    @Test
    func `deepLink should replace path with new sequence and update origins when new path is provided`() {
        let controller: TestNaviController = TestNaviController()
        let newPath: [any DestinationRepresentable] = [
            TestDestination.screenA,
            TestDestination.screenB,
            TestDestination.screenB
        ]
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.deepLink(to: newPath)
        #expect(controller.properties.path.count == 3)
        // TODO: - Check screenC is not in origin keys
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 3)
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
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 1)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenC.key] == nil)
    }

    @Test
    func `pop should not modify stack when target origin is already topmost`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.pop(to: TestDestination.Origins.screenC)
        #expect(controller.properties.path.count == 3)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenC.key] == 3)
    }

    @Test
    func `push should update existing origin index when same origin appears again`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        #expect(controller.properties.path.count == 3)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 3)
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
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenC.key] == 2)
    }

    @Test
    func `push after simulated back navigation updates origin to the latest count`() {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenC(randomData: "testData"))

        // Simulate two swipe-backs: direct NavigationPath mutation, bypassing pop().
        controller.properties.path.removeLast(2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenC.key] == 3)

        // Navigate back to the same screen; it now sits at a shallower depth.
        controller.push(to: TestDestination.screenC(randomData: "moreData"))

        #expect(controller.properties.path.count == 2)
        // Origin updated to the latest count (2), not the stale 3.
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenC.key] == 2)
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
            TestDestination.screenB
        ]

        controller.deepLink(to: newPath)

        #expect(controller.properties.path.count == 2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenB.key] == 2)
        #expect(controller.properties.naviStackOrigins[TestDestination.Origins.screenC.key] == nil)
    }

    @Test
    func `push should log appended destination when destination has no navigation origin`() throws {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenA)

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with the new destination (and origin) successfully."
        ])
        #expect(controller.logger.logInfoCallsCount == 1)
        #expect(controller.logger.logErrorCalled == false)

        let info = controller.logger.logInfoReceivedInfoModels.first
        let destiantion = try #require(info?.rawData.destination as? TestDestination)
        #expect(destiantion == TestDestination.screenA)
        #expect(info?.rawData.pathCount == 1)
        #expect(info?.rawData.origin == nil)
    }

    @Test
    func `push should log appended destination and origin when destination has navigation origin`() throws {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with the new destination (and origin) successfully."
        ])
        #expect(controller.logger.logInfoCallsCount == 1)
        #expect(controller.logger.logErrorCalled == false)

        let info = controller.logger.logInfoReceivedInfoModels.first
        let destiantion = try #require(info?.rawData.destination as? TestDestination)
        #expect(destiantion == TestDestination.screenB)
        #expect(info?.rawData.pathCount == 1)
        #expect(info?.rawData.origin?.key == TestDestination.Origins.screenB.key)
        #expect(info?.message == "Path appended with the new destination (and origin) successfully.")
    }

    @Test
    func `pop should log last path element removed when stack is not empty`() throws {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenA)
        controller.pop()

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with the new destination (and origin) successfully.",
            "Last path element removed."
        ])
        #expect(controller.logger.logInfoCallsCount == 2)
        #expect(controller.logger.logErrorCalled == false)

        let info = try #require(controller.logger.logInfoReceivedInfoModels.last)
        #expect(info.message == "Last path element removed.")
        #expect(info.rawData.pathCount == 0)
        #expect(info.rawData.destination == nil)
        #expect(info.rawData.origin == nil)
    }

    @Test
    func `pop should log removed origin when popped destination has navigation origin`() throws {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.pop()

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with the new destination (and origin) successfully.",
            "Path appended with the new destination (and origin) successfully.",
            "Navigation origin removed.",
            "Last path element removed."
        ])
        #expect(controller.logger.logInfoCallsCount == 4)
        #expect(controller.logger.logErrorCalled == false)

        let models = controller.logger.logInfoReceivedInfoModels
        #expect(models.count == 4)
        #expect(models[2].message == "Navigation origin removed.")
        #expect(models[2].rawData.pathCount == 1)
        #expect(models[2].rawData.destination == nil)
        #expect(models[2].rawData.origin == nil)
        #expect(models[3].message == "Last path element removed.")
        #expect(models[3].rawData.pathCount == 1)
    }

    @Test
    func `popToRoot should log origins cleared and path cleared`() throws {
        let controller: TestNaviController = TestNaviController()

        controller.push(to: TestDestination.screenB)
        controller.popToRoot()

        #expect(controller.logger.logInfoReceivedInvocations == [
            "Path appended with the new destination (and origin) successfully.",
            "All navigation origins cleared.",
            "Navigation path cleared."
        ])
        #expect(controller.logger.logInfoCallsCount == 3)
        #expect(controller.logger.logErrorCalled == false)

        let models = controller.logger.logInfoReceivedInfoModels
        #expect(models.count == 3)
        #expect(models[1].message == "All navigation origins cleared.")
        #expect(models[1].rawData.pathCount == 0)
        #expect(models[2].message == "Navigation path cleared.")
        #expect(models[2].rawData.pathCount == 0)
    }

    @Test
    func `deepLink should log root clearing pushed destinations and final path`() throws {
        let controller: TestNaviController = TestNaviController()
        let newPath: [any DestinationRepresentable] = [
            TestDestination.screenA,
            TestDestination.screenB
        ]

        controller.deepLink(to: newPath)

        #expect(controller.logger.logInfoReceivedInvocations == [
            "All navigation origins cleared.",
            "Navigation path cleared.",
            "Path appended with the new destination (and origin) successfully.",
            "Path appended with the new destination (and origin) successfully.",
            "Deep-link path set to new path."
        ])
        #expect(controller.logger.logInfoCallsCount == 5)
        #expect(controller.logger.logErrorCalled == false)

        let models = controller.logger.logInfoReceivedInfoModels
        #expect(models.count == 5)
        let finalInfo = try #require(models.last)
        #expect(finalInfo.message == "Deep-link path set to new path.")
        #expect(finalInfo.rawData.pathCount == 2)
        let pushedInfo = try #require(models.dropLast().last)
        let pushedDestination = try #require(pushedInfo.rawData.destination as? TestDestination)
        #expect(pushedDestination == TestDestination.screenB)
        #expect(pushedInfo.rawData.origin?.key == TestDestination.Origins.screenB.key)
        #expect(pushedInfo.rawData.pathCount == 2)
    }

    @Test
    func `pop to known origin should log popping back to origin`() throws {
        let controller: TestNaviController = TestNaviController()
        controller.push(to: TestDestination.screenA)
        controller.push(to: TestDestination.screenB)
        controller.push(to: TestDestination.screenC(randomData: "testData"))
        controller.pop(to: TestDestination.Origins.screenB)

        #expect(controller.properties.path.count == 2)
        #expect(controller.logger.logErrorCalled == false)
        let popInfo = try #require(
            controller.logger.logInfoReceivedInfoModels.first(where: { $0.message == "Popping back to origin." })
        )
        #expect(popInfo.rawData.origin?.key == TestDestination.Origins.screenB.key)
        #expect(popInfo.rawData.pathCount == 3)
    }
}

//
//  DestinationRepresentableRuntimeTests.swift
//  Navi
//

import Testing
import Navi

// MARK: - DestinationRepresentable Runtime

@Suite("DestinationRepresentable Macro Runtime")
struct DestinationRepresentableRuntimeTests {

    @DestinationRepresentable
    enum Destination {
        @OriginKey case home
        case profile
    }

    @DestinationRepresentable
    enum MultiDestination {
        @OriginKey case home
        @OriginKey case settings
        @OriginKey case profile(userId: String)
        case list
    }

    // A keyword-named case marked with @OriginKey compiles end-to-end only
    // because the macro strips backticks when generating `defaultOrigin`.
    @DestinationRepresentable
    enum KeywordDestination {
        @OriginKey case `default`
        case profile
    }

    // Pre-declaring the conformance compiles only because the extension role
    // bails when `conformingTo` is empty; without that guard the macro would
    // emit a redundant `extension … : DestinationRepresentable`.
    @DestinationRepresentable
    enum PreConformingDestination: DestinationRepresentable {
        @OriginKey case home
        case profile
    }

    // NOTE: A generic enum cannot carry @OriginKey cases — the generated
    // `static let …Origin` is a static stored property, which Swift forbids
    // in generic types. This suite only verifies that the conformance itself
    // compiles for a generic enum, which requires the `where T: Hashable`
    // clause emitted by the macro.
    @DestinationRepresentable
    enum GenericDestination<T: Hashable> {
        case detail(T)
        case list
    }

    @Test
    func `marked case returns its generated origin key`() {
        #expect(Destination.home.navigationOrigin == Destination.homeOrigin)
    }

    @Test
    func `unmarked case has no navigation origin`() {
        #expect(Destination.profile.navigationOrigin == nil)
    }

    @Test
    func `generic enum conforms via the where T Hashable clause`() {
        // Compiles only because the macro emits `where T: Hashable`; without
        // it the Hashable-refining conformance would fail to type-check.
        #expect(GenericDestination<Int>.detail(1).navigationOrigin == nil)
        #expect(GenericDestination<Int>.list.navigationOrigin == nil)
    }

    @Test
    func `each marked case returns a distinct, stable origin key`() {
        #expect(MultiDestination.home.navigationOrigin == MultiDestination.homeOrigin)
        #expect(MultiDestination.settings.navigationOrigin == MultiDestination.settingsOrigin)
        #expect(MultiDestination.homeOrigin != MultiDestination.settingsOrigin)
        #expect(MultiDestination.list.navigationOrigin == nil)
    }

    @Test
    func `origin key is independent of the associated-value payload`() {
        #expect(MultiDestination.profile(userId: "1").navigationOrigin == MultiDestination.profileOrigin)
        #expect(
            MultiDestination.profile(userId: "1").navigationOrigin
            == MultiDestination.profile(userId: "2").navigationOrigin
        )
    }

    @Test
    func `destination is usable as a Set element via synthesized Hashable`() {
        let set: Set<MultiDestination> = [.home, .home, .settings]
        #expect(set.count == 2)
    }

    @Test
    func `keyword-named marked case resolves its stripped origin key`() {
        #expect(KeywordDestination.`default`.navigationOrigin == KeywordDestination.defaultOrigin)
        #expect(KeywordDestination.profile.navigationOrigin == nil)
    }

    @Test
    func `enum that pre-declares the conformance still resolves its origin key`() {
        #expect(PreConformingDestination.home.navigationOrigin == PreConformingDestination.homeOrigin)
        #expect(PreConformingDestination.profile.navigationOrigin == nil)
    }
}

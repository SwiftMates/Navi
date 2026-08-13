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
        @OriginKey case first
        case second
    }

    @DestinationRepresentable
    enum MultiDestination {
        @OriginKey case first
        @OriginKey case third
        @OriginKey case second(identifier: String)
        case list
    }

    // A keyword-named case marked with @OriginKey compiles end-to-end only
    // because the macro strips backticks when generating `defaultOrigin`.
    @DestinationRepresentable
    enum KeywordDestination {
        @OriginKey case `default`
        case second
    }

    // Pre-declaring the conformance compiles only because the extension role
    // bails when `conformingTo` is empty; without that guard the macro would
    // emit a redundant `extension … : DestinationRepresentable`.
    @DestinationRepresentable
    enum PreConformingDestination: DestinationRepresentable {
        @OriginKey case first
        case second
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

    // The macro deliberately does not propagate @available anywhere: not onto the generated
    // origin keys, and not onto the conformance extension. The versions here sit ABOVE the
    // package's iOS 17 / macOS 14 deployment targets, so the annotation is not vacuous and
    // this fixture fails to compile if that decision turns out to be wrong. Both platforms
    // are named because `swift test` runs on macOS, where an iOS-only clause proves nothing.
    @available(iOS 26, macOS 26, *)
    @DestinationRepresentable
    enum FutureDestination {
        @OriginKey case home
        case settings
    }

    // Verifies the macro yields to a user-declared `navigationOrigin` (skips generating its own,
    // so this compiles without an invalid redeclaration) while still generating the origin keys
    // and the conformance. The witness deliberately returns `firstOrigin` for every case so the
    // runtime check proves the user's version wins over the generated switch (which would nil out
    // `.second`).
    @DestinationRepresentable
    enum CustomOriginDestination {
        @OriginKey case first
        case second

        var navigationOrigin: NavigationOriginKey? {
            Self.firstOrigin
        }
    }

    @Test
    func `marked case returns its generated origin key`() {
        #expect(Destination.first.navigationOrigin == Destination.firstOrigin)
    }

    @Test
    func `unmarked case has no navigation origin`() {
        #expect(Destination.second.navigationOrigin == nil)
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
        #expect(MultiDestination.first.navigationOrigin == MultiDestination.firstOrigin)
        #expect(MultiDestination.third.navigationOrigin == MultiDestination.thirdOrigin)
        #expect(MultiDestination.firstOrigin != MultiDestination.thirdOrigin)
        #expect(MultiDestination.list.navigationOrigin == nil)
    }

    @Test
    func `origin key is independent of the associated-value payload`() {
        #expect(MultiDestination.second(identifier: "1").navigationOrigin == MultiDestination.secondOrigin)
        #expect(
            MultiDestination.second(identifier: "1").navigationOrigin
            == MultiDestination.second(identifier: "2").navigationOrigin
        )
    }

    @Test
    func `destination is usable as a Set element via synthesized Hashable`() {
        let set: Set<MultiDestination> = [.first, .first, .third]
        #expect(set.count == 2)
    }

    @Test
    func `keyword-named marked case resolves its stripped origin key`() {
        #expect(KeywordDestination.`default`.navigationOrigin == KeywordDestination.defaultOrigin)
        #expect(KeywordDestination.second.navigationOrigin == nil)
    }

    @Test
    func `enum that pre-declares the conformance still resolves its origin key`() {
        #expect(PreConformingDestination.first.navigationOrigin == PreConformingDestination.firstOrigin)
        #expect(PreConformingDestination.second.navigationOrigin == nil)
    }

    @Test
    @available(iOS 26, macOS 26, *)
    func `available enum resolves its origin key without availability propagation`() {
        #expect(FutureDestination.home.navigationOrigin == FutureDestination.homeOrigin)
        #expect(FutureDestination.settings.navigationOrigin == nil)
    }

    @Test
    func `user-declared navigationOrigin wins over the generated one`() {
        // The user's witness returns firstOrigin for every case; the generated switch would have
        // returned nil for .second. Both compiling and this expectation prove no generated
        // navigationOrigin was emitted alongside it.
        #expect(CustomOriginDestination.first.navigationOrigin == CustomOriginDestination.firstOrigin)
        #expect(CustomOriginDestination.second.navigationOrigin == CustomOriginDestination.firstOrigin)
    }
}

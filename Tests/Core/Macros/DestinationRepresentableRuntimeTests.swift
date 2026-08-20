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
    // because the macro strips backticks when generating `defaultOriginKey`.
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
    // `static let …OriginKey` is a static stored property, which Swift
    // forbids in generic types (and in types nested inside them). This
    // suite only verifies that the conformance itself compiles for a
    // generic enum, which requires the `where T: Hashable` clause emitted
    // by the macro.
    @DestinationRepresentable
    enum GenericDestination<T: Hashable> {
        case detail(T)
        case list
    }

    @Test
    func `marked case returns its generated origin key`() {
        #expect(Destination.first.navigationOrigin?.key == Destination.Origins.first.key)
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
        #expect(MultiDestination.first.navigationOrigin?.key == MultiDestination.Origins.first.key)
        #expect(MultiDestination.third.navigationOrigin?.key == MultiDestination.Origins.third.key)
        #expect(MultiDestination.Origins.first.key != MultiDestination.Origins.third.key)
        #expect(MultiDestination.list.navigationOrigin == nil)
    }

    @Test
    func `origin key is independent of the associated-value payload`() {
        #expect(
            MultiDestination.second(identifier: "1").navigationOrigin?.key
            == MultiDestination.Origins.second.key
        )
        #expect(
            MultiDestination.second(identifier: "1").navigationOrigin?.key
            == MultiDestination.second(identifier: "2").navigationOrigin?.key
        )
    }

    @Test
    func `destination is usable as a Set element via synthesized Hashable`() {
        let set: Set<MultiDestination> = [.first, .first, .third]
        #expect(set.count == 2)
    }

    @Test
    func `keyword-named marked case resolves its stripped origin key`() {
        #expect(
            KeywordDestination.`default`.navigationOrigin?.key
            == KeywordDestination.Origins.`default`.key
        )
        #expect(KeywordDestination.second.navigationOrigin == nil)
    }

    @Test
    func `enum that pre-declares the conformance still resolves its origin key`() {
        #expect(
            PreConformingDestination.first.navigationOrigin?.key
            == PreConformingDestination.Origins.first.key
        )
        #expect(PreConformingDestination.second.navigationOrigin == nil)
    }

    // MARK: - New cases worth adding

    @Test
    func `Origins enum conforms to OriginRepresentable`() {
        // Guards against a regression where `Origins` is generated but its
        // conformance clause is dropped or misspelled.
        let origin: any OriginRepresentable = MultiDestination.Origins.first
        #expect(origin.key == MultiDestination.Origins.first.key)
    }

    @Test
    func `distinct Origins cases have distinct keys`() {
        // Ensures each generated `<case>OriginKey` is its own NavigationOriginKey
        // instance, not a shared/aliased value.
        let keys: Set<NavigationOriginKey> = [
            MultiDestination.Origins.first.key,
            MultiDestination.Origins.second.key,
            MultiDestination.Origins.third.key
        ]
        #expect(keys.count == 3)
    }

    @Test
    func `Origins case key is stable across accesses`() {
        // The origin key is a static let, so it must be identical on every read.
        #expect(MultiDestination.Origins.first.key == MultiDestination.Origins.first.key)
    }

    @Test
    func `origin keys are distinct across enums for the same case name`() {
        // Two different enums each declaring `@OriginKey case first` must not
        // collide — each generates its own NavigationOriginKey instance.
        #expect(Destination.Origins.first.key != MultiDestination.Origins.first.key)
    }
}

//
//  DestinationRepresentableMacroTests.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 22..
//

import Testing
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
@testable import NaviMacrosPlugin

// MARK: - DestinationRepresentable

@Suite("DestinationRepresentable Macro")
struct DestinationRepresentableMacroTests {

    let macros: [String: MacroSpec] = [
        "DestinationRepresentable": MacroSpec(
            type: DestinationRepresentableMacro.self,
            conformances: [TypeSyntax("DestinationRepresentable")]
        ),
        "OriginKey": MacroSpec(type: OriginKeyMacro.self)
    ]

    // MARK: - Basic expansion

    @Test
    func `expansion should return nil for all cases when no case is marked with OriginKey`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                case home
                case profile
                case test
            }
            """,
            expandedSource: """
            enum Destination {
                case home
                case profile
                case test

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return nil
                    case .profile:
                        return nil
                    case .test:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }
    
    @Test
    func `expansion should return nil for all cases when no case is marked with OriginKey and cases are enumerated`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                case home, profile, test
            }
            """,
            expandedSource: """
            enum Destination {
                case home, profile, test

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return nil
                    case .profile:
                        return nil
                    case .test:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }
    
    @Test
    func `expansion should return nil for all cases when no case is marked with OriginKey and cases are enumerated and in different order`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                case home, profile
                case test
            }
            """,
            expandedSource: """
            enum Destination {
                case home, profile
                case test

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return nil
                    case .profile:
                        return nil
                    case .test:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Single @OriginKey

    @Test
    func `expansion should generate a static key and return it when a single case is marked with OriginKey`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case home
                case profile
            }
            """,
            expandedSource: """
            enum Destination {
                case home
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    case .profile:
                        return nil
                    }
                }
            
                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Multiple @OriginKey

    @Test
    func `expansion should generate a static key for every case marked with OriginKey when multiple cases are marked`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey
                case home
                @OriginKey
                case settings
                case profile
            }
            """,
            expandedSource: """
            enum Destination {
                case home
                case settings
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    case .settings:
                        return Self.settingsOrigin
                    case .profile:
                        return nil
                    }
                }
            
                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")

                static let settingsOrigin = NavigationOriginKey(debugName: "Destination - settings Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - All cases marked

    @Test
    func `expansion should generate a static key for every case when all cases are marked with OriginKey`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey
                case home
                @OriginKey
                case profile
            }
            """,
            expandedSource: """
            enum Destination {
                case home
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    case .profile:
                        return Self.profileOrigin
                    }
                }
            
                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
            
                static let profileOrigin = NavigationOriginKey(debugName: "Destination - profile Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Multiple elements per case declaration

    @Test
    func `expansion should generate a separate static key for each element when multiple cases share the same OriginKey declaration`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey
                case home, settings, about
                case profile
            }
            """,
            expandedSource: """
            enum Destination {
                case home, settings, about
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    case .settings:
                        return Self.settingsOrigin
                    case .about:
                        return Self.aboutOrigin
                    case .profile:
                        return nil
                    }
                }
            
                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
            
                static let settingsOrigin = NavigationOriginKey(debugName: "Destination - settings Origin")
            
                static let aboutOrigin = NavigationOriginKey(debugName: "Destination - about Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Associated values

    @Test
    func `expansion should ignore associated values and still generate the correct static key when a case has named associated values`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey
                case profile(userId: String)
                case settings(darkMode: Bool, language: String)
                case home
            }
            """,
            expandedSource: """
            enum Destination {
                case profile(userId: String)
                case settings(darkMode: Bool, language: String)
                case home

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .profile:
                        return Self.profileOrigin
                    case .settings:
                        return nil
                    case .home:
                        return nil
                    }
                }
            
                static let profileOrigin = NavigationOriginKey(debugName: "Destination - profile Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should generate correct switch when a case has unnamed associated values`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey
                case detail(String, Int)
                case list
            }
            """,
            expandedSource: """
            enum Destination {
                case detail(String, Int)
                case list

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .detail:
                        return Self.detailOrigin
                    case .list:
                        return nil
                    }
                }
            
                static let detailOrigin = NavigationOriginKey(debugName: "Destination - detail Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Nested enums

    @Test
    func `expansion should generate the correct extension when the enum is nested inside another type`() {
        assertMacroExpansion(
            """
            struct HomeCoordinator {
                @DestinationRepresentable
                enum Destination {
                    @OriginKey
                    case home
                    case profile
                }
            }
            """,
            expandedSource: """
            struct HomeCoordinator {
                enum Destination {
                    case home
                    case profile

                    public var navigationOrigin: NavigationOriginKey? {
                        switch self {
                        case .home:
                            return Self.homeOrigin
                        case .profile:
                            return nil
                        }
                    }
            
                    static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
                }
            }

            extension HomeCoordinator.Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Generic enums

    @Test
    func `expansion should diagnose when OriginKey is applied to a case of a generic enum`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination<T> {
                @OriginKey
                case detail(T)
                case list
            }
            """,
            expandedSource: """
            enum Destination<T> {
                case detail(T)
                case list
            }

            extension Destination: DestinationRepresentable where T: Hashable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@OriginKey is not supported on a case of a generic enum, because its generated origin key would be a static stored property, which Swift does not allow in generic types",
                    line: 3,
                    column: 5
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should emit one diagnostic per OriginKey case in a generic enum`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination<T> {
                @OriginKey
                case detail(T)
                @OriginKey
                case summary(T)
                case list
            }
            """,
            expandedSource: """
            enum Destination<T> {
                case detail(T)
                case summary(T)
                case list
            }

            extension Destination: DestinationRepresentable where T: Hashable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@OriginKey is not supported on a case of a generic enum, because its generated origin key would be a static stored property, which Swift does not allow in generic types",
                    line: 3,
                    column: 5
                ),
                DiagnosticSpec(
                    message: "@OriginKey is not supported on a case of a generic enum, because its generated origin key would be a static stored property, which Swift does not allow in generic types",
                    line: 5,
                    column: 5
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should generate members and constrained conformance for a generic enum without OriginKey`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination<T> {
                case detail(T)
                case list
            }
            """,
            expandedSource: """
            enum Destination<T> {
                case detail(T)
                case list

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .detail:
                        return nil
                    case .list:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable where T: Hashable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Empty enum

    @Test
    func `expansion should generate an empty switch when the enum has no cases`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
            }
            """,
            expandedSource: """
            enum Destination {

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Error cases

    @Test
    func `expansion should produce an error when DestinationRepresentable is applied to a struct`() throws {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            struct NotAnEnum {}
            """,
            expandedSource: """
            struct NotAnEnum {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@DestinationRepresentable can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should produce an error when DestinationRepresentable is applied to a class`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            class NotAnEnum {}
            """,
            expandedSource: """
            class NotAnEnum {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@DestinationRepresentable can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should produce an error when DestinationRepresentable is applied to an actor`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            actor NotAnEnum {}
            """,
            expandedSource: """
            actor NotAnEnum {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@DestinationRepresentable can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should produce an error when DestinationRepresentable is applied to a protocol`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            protocol NotAnEnum {}
            """,
            expandedSource: """
            protocol NotAnEnum {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@DestinationRepresentable can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    // MARK: - Single case

    @Test
    func `expansion should generate a single-nil switch when the enum has one unmarked case`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                case home
            }
            """,
            expandedSource: """
            enum Destination {
                case home

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should generate a key and switch when the enum has one marked case`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case home
            }
            """,
            expandedSource: """
            enum Destination {
                case home

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    }
                }

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Raw-value enums

    @Test
    func `expansion should preserve the raw type and add conformance in a separate extension`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination: String {
                case home
                case profile
            }
            """,
            expandedSource: """
            enum Destination: String {
                case home
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return nil
                    case .profile:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should ignore assigned raw values when generating the switch`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination: String {
                @OriginKey case home = "home_screen"
                case profile = "profile_screen"
            }
            """,
            expandedSource: """
            enum Destination: String {
                case home = "home_screen"
                case profile = "profile_screen"

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    case .profile:
                        return nil
                    }
                }

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should keep an existing protocol conformance on the enum`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination: Codable {
                case home
                case profile
            }
            """,
            expandedSource: """
            enum Destination: Codable {
                case home
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return nil
                    case .profile:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Indirect enums

    @Test
    func `expansion should preserve the indirect modifier on the enum`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            indirect enum Destination {
                case node(Destination)
                case leaf
            }
            """,
            expandedSource: """
            indirect enum Destination {
                case node(Destination)
                case leaf

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .node:
                        return nil
                    case .leaf:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should preserve an indirect case modifier`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey indirect case node(Destination)
                case leaf
            }
            """,
            expandedSource: """
            enum Destination {
                indirect case node(Destination)
                case leaf

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .node:
                        return Self.nodeOrigin
                    case .leaf:
                        return nil
                    }
                }

                static let nodeOrigin = NavigationOriginKey(debugName: "Destination - node Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Mixed cases

    @Test
    func `expansion should mix marked and unmarked cases with associated values correctly`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case detail(id: Int)
                case list
                @OriginKey case search
            }
            """,
            expandedSource: """
            enum Destination {
                case detail(id: Int)
                case list
                case search

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .detail:
                        return Self.detailOrigin
                    case .list:
                        return nil
                    case .search:
                        return Self.searchOrigin
                    }
                }

                static let detailOrigin = NavigationOriginKey(debugName: "Destination - detail Origin")

                static let searchOrigin = NavigationOriginKey(debugName: "Destination - search Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should key each element of a marked multi-element case with unnamed values`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case a(Int), b(String)
                case c
            }
            """,
            expandedSource: """
            enum Destination {
                case a(Int), b(String)
                case c

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .a:
                        return Self.aOrigin
                    case .b:
                        return Self.bOrigin
                    case .c:
                        return nil
                    }
                }

                static let aOrigin = NavigationOriginKey(debugName: "Destination - a Origin")

                static let bOrigin = NavigationOriginKey(debugName: "Destination - b Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Access modifiers

    @Test
    func `expansion should preserve a public access modifier on the enum`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            public enum Destination {
                @OriginKey case home
                case profile
            }
            """,
            expandedSource: """
            public enum Destination {
                case home
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    case .profile:
                        return nil
                    }
                }

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Attributes on cases

    @Test
    func `expansion should keep an available attribute while consuming OriginKey`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey
                @available(iOS 16, *)
                case home
                case profile
            }
            """,
            expandedSource: """
            enum Destination {
                @available(iOS 16, *)
                case home
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    case .profile:
                        return nil
                    }
                }

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Keyword / escaped case names

    @Test
    func `expansion should strip backticks so a keyword-named marked case yields a valid key`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case `default`
                case profile
            }
            """,
            expandedSource: """
            enum Destination {
                case `default`
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .`default`:
                        return Self.defaultOrigin
                    case .profile:
                        return nil
                    }
                }

                static let defaultOrigin = NavigationOriginKey(debugName: "Destination - default Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should generate a valid switch for unmarked keyword-named cases`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                case `class`, `import`
            }
            """,
            expandedSource: """
            enum Destination {
                case `class`, `import`

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .`class`:
                        return nil
                    case .`import`:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should diagnose OriginKey on a raw-identifier case and skip its key`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case `my case`
                case profile
            }
            """,
            expandedSource: """
            enum Destination {
                case `my case`
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .`my case`:
                        return nil
                    case .profile:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@OriginKey is not supported on a case whose name is a raw identifier, because the generated origin key would not be a valid Swift identifier",
                    line: 3,
                    column: 21
                )
            ],
            macros: macros
        )
    }

    // MARK: - Already conforming

    @Test
    func `expansion should not emit an extension when the type already conforms`() {
        // Mirrors the compiler passing an empty `conformingTo` list once the type
        // already states the conformance: the extension role must add nothing.
        let macros: [String: MacroSpec] = [
            "DestinationRepresentable": MacroSpec(
                type: DestinationRepresentableMacro.self,
                conformances: []
            ),
            "OriginKey": MacroSpec(type: OriginKeyMacro.self)
        ]
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination: DestinationRepresentable {
                @OriginKey case home
                case profile
            }
            """,
            expandedSource: """
            enum Destination: DestinationRepresentable {
                case home
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home:
                        return Self.homeOrigin
                    case .profile:
                        return nil
                    }
                }

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
            }
            """,
            macros: macros
        )
    }

    // MARK: - Generic enums (multiple parameters & clauses)

    @Test
    func `expansion should constrain every generic parameter to Hashable`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination<T, U> {
                case detail(T)
                case pair(T, U)
                case list
            }
            """,
            expandedSource: """
            enum Destination<T, U> {
                case detail(T)
                case pair(T, U)
                case list

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .detail:
                        return nil
                    case .pair:
                        return nil
                    case .list:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable where T: Hashable, U: Hashable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should still emit the Hashable clause when a parameter is already constrained`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination<T: Hashable> {
                case detail(T)
                case list
            }
            """,
            expandedSource: """
            enum Destination<T: Hashable> {
                case detail(T)
                case list

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .detail:
                        return nil
                    case .list:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable where T: Hashable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should preserve the enum's own where clause and add the Hashable clause`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination<T> where T: Equatable {
                case detail(T)
                case list
            }
            """,
            expandedSource: """
            enum Destination<T> where T: Equatable {
                case detail(T)
                case list

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .detail:
                        return nil
                    case .list:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable where T: Hashable {
            }
            """,
            macros: macros
        )
    }

    // MARK: - Nesting

    @Test
    func `expansion should qualify the extension for an enum nested in a generic type`() {
        assertMacroExpansion(
            """
            struct Box<T> {
                @DestinationRepresentable
                enum Destination {
                    @OriginKey case home
                    case profile
                }
            }
            """,
            expandedSource: """
            struct Box<T> {
                enum Destination {
                    case home
                    case profile

                    public var navigationOrigin: NavigationOriginKey? {
                        switch self {
                        case .home:
                            return Self.homeOrigin
                        case .profile:
                            return nil
                        }
                    }

                    static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
                }
            }

            extension Box.Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should fully qualify the extension for a deeply nested enum`() {
        assertMacroExpansion(
            """
            enum Outer {
                enum Middle {
                    @DestinationRepresentable
                    enum Destination {
                        @OriginKey case home
                        case profile
                    }
                }
            }
            """,
            expandedSource: """
            enum Outer {
                enum Middle {
                    enum Destination {
                        case home
                        case profile

                        public var navigationOrigin: NavigationOriginKey? {
                            switch self {
                            case .home:
                                return Self.homeOrigin
                            case .profile:
                                return nil
                            }
                        }

                        static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")
                    }
                }
            }

            extension Outer.Middle.Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }
}

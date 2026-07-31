//
//  DestinationRepresentableMacroTests.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 22..
//

import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import NaviMacrosPlugin

// MARK: - DestinationRepresentable

@Suite("DestinationRepresentable Macro")
struct DestinationRepresentableMacroTests {

    let macros: [String: Macro.Type] = [
        "DestinationRepresentable": DestinationRepresentableMacro.self,
        "OriginKey": OriginKeyMacro.self
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
            }
            """,
            expandedSource: """
            enum Destination {
                case home
                case profile

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home: return nil
                    case .profile: return nil
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
                @OriginKey
                case home
                case profile
            }
            """,
            expandedSource: """
            enum Destination {
                case home
                case profile

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home: return Self.homeOrigin
                    case .profile: return nil
                    }
                }
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

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")

                static let settingsOrigin = NavigationOriginKey(debugName: "Destination - settings Origin")

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home: return Self.homeOrigin
                    case .settings: return Self.settingsOrigin
                    case .profile: return nil
                    }
                }
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

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")

                static let profileOrigin = NavigationOriginKey(debugName: "Destination - profile Origin")

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home: return Self.homeOrigin
                    case .profile: return Self.profileOrigin
                    }
                }
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

                static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")

                static let settingsOrigin = NavigationOriginKey(debugName: "Destination - settings Origin")

                static let aboutOrigin = NavigationOriginKey(debugName: "Destination - about Origin")

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .home: return Self.homeOrigin
                    case .settings: return Self.settingsOrigin
                    case .about: return Self.aboutOrigin
                    case .profile: return nil
                    }
                }
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

                static let profileOrigin = NavigationOriginKey(debugName: "Destination - profile Origin")

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .profile: return Self.profileOrigin
                    case .settings: return nil
                    case .home: return nil
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

                static let detailOrigin = NavigationOriginKey(debugName: "Destination - detail Origin")

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .detail: return Self.detailOrigin
                    case .list: return nil
                    }
                }
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
            extension HomeCoordinator {
                @DestinationRepresentable
                enum Destination {
                    @OriginKey
                    case home
                    case profile
                }
            }
            """,
            expandedSource: """
            extension HomeCoordinator {
                enum Destination {
                    case home
                    case profile

                    static let homeOrigin = NavigationOriginKey(debugName: "Destination - home Origin")

                    public var navigationOrigin: NavigationOriginKey? {
                        switch self {
                        case .home: return Self.homeOrigin
                        case .profile: return nil
                        }
                    }
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
    func `expansion should generate the correct extension when the enum is generic`() {
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

                static let detailOrigin = NavigationOriginKey(debugName: "Destination - detail Origin")

                public var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .detail: return Self.detailOrigin
                    case .list: return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
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
    func `expansion should produce an error when DestinationRepresentable is applied to a struct`() {
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
}

// MARK: - OriginKey

@Suite("OriginKey Macro")
struct OriginKeyMacroTests {

    let macros: [String: Macro.Type] = [
        "OriginKey": OriginKeyMacro.self
    ]

    @Test
    func `expansion should produce no additional code when OriginKey is applied to a single enum case`() {
        assertMacroExpansion(
            """
            enum Destination {
                @OriginKey
                case home
            }
            """,
            expandedSource: """
            enum Destination {
                case home
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should produce no additional code when OriginKey is applied to a case with multiple elements`() {
        assertMacroExpansion(
            """
            enum Destination {
                @OriginKey
                case home, settings, about
            }
            """,
            expandedSource: """
            enum Destination {
                case home, settings, about
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should produce no additional code when OriginKey is applied to multiple separate cases`() {
        assertMacroExpansion(
            """
            enum Destination {
                @OriginKey
                case home
                @OriginKey
                case settings
            }
            """,
            expandedSource: """
            enum Destination {
                case home
                case settings
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should produce an error when OriginKey is applied to a struct`() {
        assertMacroExpansion(
            """
            @OriginKey
            struct Wrong {}
            """,
            expandedSource: """
            struct Wrong {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@OriginKey can only be applied to an enum case",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should produce an error when OriginKey is applied to a function`() {
        assertMacroExpansion(
            """
            @OriginKey
            func wrong() {}
            """,
            expandedSource: """
            func wrong() {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@OriginKey can only be applied to an enum case",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should produce an error when OriginKey is applied to a property`() {
        assertMacroExpansion(
            """
            @OriginKey
            var wrong: Int = 0
            """,
            expandedSource: """
            var wrong: Int = 0
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@OriginKey can only be applied to an enum case",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }
}

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
                case first
                case second
                case test
            }
            """,
            expandedSource: """
            enum Destination {
                case first
                case second
                case test

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return nil
                    case .second:
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
                case first, second, test
            }
            """,
            expandedSource: """
            enum Destination {
                case first, second, test

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return nil
                    case .second:
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
                case first, second
                case test
            }
            """,
            expandedSource: """
            enum Destination {
                case first, second
                case test

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return nil
                    case .second:
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
                @OriginKey case first
                case second
            }
            """,
            expandedSource: """
            enum Destination {
                case first
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    case .second:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
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
                case first
                @OriginKey
                case third
                case second
            }
            """,
            expandedSource: """
            enum Destination {
                case first
                case third
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    case .third:
                        return Origins.third
                    case .second:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    case third
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        case .third:
                            Self.thirdOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                    static private let thirdOriginKey = NavigationOriginKey(debugName: "Destination - third Origin")
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
                case first
                @OriginKey
                case second
            }
            """,
            expandedSource: """
            enum Destination {
                case first
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    case .second:
                        return Origins.second
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    case second
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        case .second:
                            Self.secondOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                    static private let secondOriginKey = NavigationOriginKey(debugName: "Destination - second Origin")
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
                case first, third, fourth
                case second
            }
            """,
            expandedSource: """
            enum Destination {
                case first, third, fourth
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    case .third:
                        return Origins.third
                    case .fourth:
                        return Origins.fourth
                    case .second:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    case third
                    case fourth
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        case .third:
                            Self.thirdOriginKey
                        case .fourth:
                            Self.fourthOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                    static private let thirdOriginKey = NavigationOriginKey(debugName: "Destination - third Origin")
                    static private let fourthOriginKey = NavigationOriginKey(debugName: "Destination - fourth Origin")
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
                case second(identifier: String)
                case third(flag: Bool, label: String)
                case first
            }
            """,
            expandedSource: """
            enum Destination {
                case second(identifier: String)
                case third(flag: Bool, label: String)
                case first

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .second:
                        return Origins.second
                    case .third:
                        return nil
                    case .first:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case second
                    var key: NavigationOriginKey {
                        switch self {
                        case .second:
                            Self.secondOriginKey
                        }
                    }
                    static private let secondOriginKey = NavigationOriginKey(debugName: "Destination - second Origin")
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

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .detail:
                        return Origins.detail
                    case .list:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case detail
                    var key: NavigationOriginKey {
                        switch self {
                        case .detail:
                            Self.detailOriginKey
                        }
                    }
                    static private let detailOriginKey = NavigationOriginKey(debugName: "Destination - detail Origin")
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
            struct Container {
                @DestinationRepresentable
                enum Destination {
                    @OriginKey
                    case first
                    case second
                }
            }
            """,
            expandedSource: """
            struct Container {
                enum Destination {
                    case first
                    case second

                    var navigationOrigin: (any OriginRepresentable)? {
                        switch self {
                        case .first:
                            return Origins.first
                        case .second:
                            return nil
                        }
                    }

                    enum Origins: OriginRepresentable {
                        case first
                        var key: NavigationOriginKey {
                            switch self {
                            case .first:
                                Self.firstOriginKey
                            }
                        }
                        static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                    }
                }
            }

            extension Container.Destination: DestinationRepresentable {
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

                var navigationOrigin: (any OriginRepresentable)? {
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
    func `expansion should produce an error when the enum has no cases`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
            }
            """,
            expandedSource: """
            enum Destination {
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@DestinationRepresentable can only be applied to an enum with at least one case",
                    line: 2,
                    column: 6
                )
            ],
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
                case first
            }
            """,
            expandedSource: """
            enum Destination {
                case first

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
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
                @OriginKey case first
            }
            """,
            expandedSource: """
            enum Destination {
                case first

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                }
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
                case first
                case second
            }
            """,
            expandedSource: """
            enum Destination: String {
                case first
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return nil
                    case .second:
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
                @OriginKey case first = "first_value"
                case second = "second_value"
            }
            """,
            expandedSource: """
            enum Destination: String {
                case first = "first_value"
                case second = "second_value"

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    case .second:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                }
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
                case first
                case second
            }
            """,
            expandedSource: """
            enum Destination: Codable {
                case first
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return nil
                    case .second:
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

                var navigationOrigin: (any OriginRepresentable)? {
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

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .node:
                        return Origins.node
                    case .leaf:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case node
                    var key: NavigationOriginKey {
                        switch self {
                        case .node:
                            Self.nodeOriginKey
                        }
                    }
                    static private let nodeOriginKey = NavigationOriginKey(debugName: "Destination - node Origin")
                }
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

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .detail:
                        return Origins.detail
                    case .list:
                        return nil
                    case .search:
                        return Origins.search
                    }
                }

                enum Origins: OriginRepresentable {
                    case detail
                    case search
                    var key: NavigationOriginKey {
                        switch self {
                        case .detail:
                            Self.detailOriginKey
                        case .search:
                            Self.searchOriginKey
                        }
                    }
                    static private let detailOriginKey = NavigationOriginKey(debugName: "Destination - detail Origin")
                    static private let searchOriginKey = NavigationOriginKey(debugName: "Destination - search Origin")
                }
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

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .a:
                        return Origins.a
                    case .b:
                        return Origins.b
                    case .c:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case a
                    case b
                    var key: NavigationOriginKey {
                        switch self {
                        case .a:
                            Self.aOriginKey
                        case .b:
                            Self.bOriginKey
                        }
                    }
                    static private let aOriginKey = NavigationOriginKey(debugName: "Destination - a Origin")
                    static private let bOriginKey = NavigationOriginKey(debugName: "Destination - b Origin")
                }
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
                @OriginKey case first
                case second
            }
            """,
            expandedSource: """
            public enum Destination {
                case first
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    case .second:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                }
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
                case first
                case second
            }
            """,
            expandedSource: """
            enum Destination {
                @available(iOS 16, *)
                case first
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    case .second:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                }
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
                case second
            }
            """,
            expandedSource: """
            enum Destination {
                case `default`
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .`default`:
                        return Origins.default
                    case .second:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case `default`
                    var key: NavigationOriginKey {
                        switch self {
                        case .`default`:
                            Self.defaultOriginKey
                        }
                    }
                    static private let defaultOriginKey = NavigationOriginKey(debugName: "Destination - default Origin")
                }
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

                var navigationOrigin: (any OriginRepresentable)? {
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
                case second
            }
            """,
            expandedSource: """
            enum Destination {
                case `my case`
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .`my case`:
                        return nil
                    case .second:
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
                @OriginKey case first
                case second
            }
            """,
            expandedSource: """
            enum Destination: DestinationRepresentable {
                case first
                case second

                var navigationOrigin: (any OriginRepresentable)? {
                    switch self {
                    case .first:
                        return Origins.first
                    case .second:
                        return nil
                    }
                }

                enum Origins: OriginRepresentable {
                    case first
                    var key: NavigationOriginKey {
                        switch self {
                        case .first:
                            Self.firstOriginKey
                        }
                    }
                    static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                }
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

                var navigationOrigin: (any OriginRepresentable)? {
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

                var navigationOrigin: (any OriginRepresentable)? {
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

                var navigationOrigin: (any OriginRepresentable)? {
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
                    @OriginKey case first
                    case second
                }
            }
            """,
            expandedSource: """
            struct Box<T> {
                enum Destination {
                    case first
                    case second

                    var navigationOrigin: (any OriginRepresentable)? {
                        switch self {
                        case .first:
                            return Origins.first
                        case .second:
                            return nil
                        }
                    }

                    enum Origins: OriginRepresentable {
                        case first
                        var key: NavigationOriginKey {
                            switch self {
                            case .first:
                                Self.firstOriginKey
                            }
                        }
                        static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                    }
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
                        @OriginKey case first
                        case second
                    }
                }
            }
            """,
            expandedSource: """
            enum Outer {
                enum Middle {
                    enum Destination {
                        case first
                        case second

                        var navigationOrigin: (any OriginRepresentable)? {
                            switch self {
                            case .first:
                                return Origins.first
                            case .second:
                                return nil
                            }
                        }

                        enum Origins: OriginRepresentable {
                            case first
                            var key: NavigationOriginKey {
                                switch self {
                                case .first:
                                    Self.firstOriginKey
                                }
                            }
                            static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
                        }
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

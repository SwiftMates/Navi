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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return Self.firstOrigin
                    case .second:
                        return nil
                    }
                }
            
                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return Self.firstOrigin
                    case .third:
                        return Self.thirdOrigin
                    case .second:
                        return nil
                    }
                }
            
                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")

                static let thirdOrigin = NavigationOriginKey(debugName: "Destination - third Origin")
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return Self.firstOrigin
                    case .second:
                        return Self.secondOrigin
                    }
                }
            
                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
            
                static let secondOrigin = NavigationOriginKey(debugName: "Destination - second Origin")
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return Self.firstOrigin
                    case .third:
                        return Self.thirdOrigin
                    case .fourth:
                        return Self.fourthOrigin
                    case .second:
                        return nil
                    }
                }
            
                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
            
                static let thirdOrigin = NavigationOriginKey(debugName: "Destination - third Origin")
            
                static let fourthOrigin = NavigationOriginKey(debugName: "Destination - fourth Origin")
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .second:
                        return Self.secondOrigin
                    case .third:
                        return nil
                    case .first:
                        return nil
                    }
                }
            
                static let secondOrigin = NavigationOriginKey(debugName: "Destination - second Origin")
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

                var navigationOrigin: NavigationOriginKey? {
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

                    var navigationOrigin: NavigationOriginKey? {
                        switch self {
                        case .first:
                            return Self.firstOrigin
                        case .second:
                            return nil
                        }
                    }
            
                    static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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
                case first
            }
            """,
            expandedSource: """
            enum Destination {
                case first

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return Self.firstOrigin
                    }
                }

                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return Self.firstOrigin
                    case .second:
                        return nil
                    }
                }

                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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

    // MARK: - Attributes on cases

    @Test
    func `expansion should not generate a static key and preserve available on an unmarked case`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
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

                var navigationOrigin: NavigationOriginKey? {
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

    // MARK: - Available on enum

    // The macro deliberately does not copy the enum's @available onto the generated
    // conformance extension. This pins that decision so it is not reflexively re-added.
    @Test
    func `expansion should not propagate available on the enum to the conformance extension`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            @available(iOS 16, *)
            enum Destination {
                @OriginKey case first
                case second
            }
            """,
            expandedSource: """
            @available(iOS 16, *)
            enum Destination {
                case first
                case second

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return Self.firstOrigin
                    case .second:
                        return nil
                    }
                }

                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .`default`:
                        return Self.defaultOrigin
                    case .second:
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

                var navigationOrigin: NavigationOriginKey? {
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
    func `expansion should diagnose a marked raw-identifier case and generate nothing`() {
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
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@DestinationRepresentable does not support a case whose name is a raw identifier, because generated members are derived from case names and would not be valid Swift identifiers; rename the case",
                    line: 3,
                    column: 21
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should diagnose an unmarked raw-identifier case and generate nothing`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                case `my case`
                case second
            }
            """,
            expandedSource: """
            enum Destination {
                case `my case`
                case second
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@DestinationRepresentable does not support a case whose name is a raw identifier, because generated members are derived from case names and would not be valid Swift identifiers; rename the case",
                    line: 3,
                    column: 10
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should diagnose every raw-identifier case in the enum`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                case `my case`
                case `another case`
                @OriginKey case valid
            }
            """,
            expandedSource: """
            enum Destination {
                case `my case`
                case `another case`
                case valid
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@DestinationRepresentable does not support a case whose name is a raw identifier, because generated members are derived from case names and would not be valid Swift identifiers; rename the case",
                    line: 3,
                    column: 10
                ),
                DiagnosticSpec(
                    message: "@DestinationRepresentable does not support a case whose name is a raw identifier, because generated members are derived from case names and would not be valid Swift identifiers; rename the case",
                    line: 4,
                    column: 10
                )
            ],
            macros: macros
        )
    }

    // MARK: - Collisions with user declarations

    @Test
    func `expansion should not generate navigationOrigin when the enum already declares one`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case first
                case second
                var navigationOrigin: NavigationOriginKey? {
                    nil
                }
            }
            """,
            expandedSource: """
            enum Destination {
                case first
                case second
                var navigationOrigin: NavigationOriginKey? {
                    nil
                }

                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            macros: macros
        )
    }

    @Test
    func `expansion should diagnose when a generated key collides with a user member and skip it`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case first
                case second
                static let firstOrigin = NavigationOriginKey(debugName: "mine")
            }
            """,
            expandedSource: """
            enum Destination {
                case first
                case second
                static let firstOrigin = NavigationOriginKey(debugName: "mine")

                var navigationOrigin: NavigationOriginKey? {
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
            diagnostics: [
                DiagnosticSpec(
                    message: "@OriginKey cannot generate its origin key because the enum already declares a member with the generated key's name; rename the case or the conflicting declaration",
                    line: 3,
                    column: 21
                )
            ],
            macros: macros
        )
    }

    @Test
    func `expansion should diagnose when a generated key collides with a sibling case and skip it`() {
        assertMacroExpansion(
            """
            @DestinationRepresentable
            enum Destination {
                @OriginKey case first
                case firstOrigin
            }
            """,
            expandedSource: """
            enum Destination {
                case first
                case firstOrigin

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return nil
                    case .firstOrigin:
                        return nil
                    }
                }
            }

            extension Destination: DestinationRepresentable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@OriginKey cannot generate its origin key because the enum already declares a member with the generated key's name; rename the case or the conflicting declaration",
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

                var navigationOrigin: NavigationOriginKey? {
                    switch self {
                    case .first:
                        return Self.firstOrigin
                    case .second:
                        return nil
                    }
                }

                static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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

                var navigationOrigin: NavigationOriginKey? {
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

                    var navigationOrigin: NavigationOriginKey? {
                        switch self {
                        case .first:
                            return Self.firstOrigin
                        case .second:
                            return nil
                        }
                    }

                    static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
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

                        var navigationOrigin: NavigationOriginKey? {
                            switch self {
                            case .first:
                                return Self.firstOrigin
                            case .second:
                                return nil
                            }
                        }

                        static let firstOrigin = NavigationOriginKey(debugName: "Destination - first Origin")
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

//
//  OriginKeyMacroTests.swift
//  Navi
//
//  Created by Mark Lazar Kiss on 06/08/2026.
//

import Testing
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
@testable import NaviMacrosPlugin

@Suite("OriginKey Macro")
struct OriginKeyMacroTests {

    let macros: [String: MacroSpec] = [
        "OriginKey": MacroSpec(type: OriginKeyMacro.self)
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
    func `expansion should produce an error when OriginKey is applied to an enum declaration`() {
        assertMacroExpansion(
            """
            @OriginKey
            enum Wrong {
                case home
            }
            """,
            expandedSource: """
            enum Wrong {
                case home
            }
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

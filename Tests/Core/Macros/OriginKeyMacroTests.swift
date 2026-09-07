//
//  OriginKeyMacroTests.swift
//  Navi
//
//  Created by Mark Lazar Kiss on 06/08/2026.
//

import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import NaviMacrosPlugin

@Suite("OriginKey Macro")
struct OriginKeyMacroTests {

    let macros: [String: MacroSpec] = [
        "OriginKey": MacroSpec(type: OriginKeyMacro.self)
    ]

    @Test
    func
        `expansion should produce no additional code when OriginKey is applied to a single enum case`()
    {
        assertMacroExpansion(
            """
            enum Destination {
                @OriginKey
                case first
            }
            """,
            expandedSource: """
                enum Destination {
                    case first
                }
                """,
            macros: macros
        )
    }

    @Test
    func
        `expansion should produce no additional code when OriginKey is applied to a case with multiple elements`()
    {
        assertMacroExpansion(
            """
            enum Destination {
                @OriginKey
                case first, third, fourth
            }
            """,
            expandedSource: """
                enum Destination {
                    case first, third, fourth
                }
                """,
            macros: macros
        )
    }

    @Test
    func
        `expansion should produce no additional code when OriginKey is applied to multiple separate cases`()
    {
        assertMacroExpansion(
            """
            enum Destination {
                @OriginKey
                case first
                @OriginKey
                case third
            }
            """,
            expandedSource: """
                enum Destination {
                    case first
                    case third
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
                case first
            }
            """,
            expandedSource: """
                enum Wrong {
                    case first
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

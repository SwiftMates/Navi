//
//  AssertMacroExpansion.swift
//  Navi
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

/// Swift Testing-aware `assertMacroExpansion`: forwards to the generic
/// SwiftSyntax test support and reports failures via `Issue.record`
/// instead of XCTest's `XCTFail`.
func assertMacroExpansion(
    _ originalSource: String,
    expandedSource expectedExpandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    macros: [String: MacroSpec],
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    SwiftSyntaxMacrosGenericTestSupport.assertMacroExpansion(
        originalSource,
        expandedSource: expectedExpandedSource,
        diagnostics: diagnostics,
        macroSpecs: macros,
        indentationWidth: .spaces(4),
        failureHandler: { spec in
            Issue.record(
                "\(spec.message)",
                sourceLocation: SourceLocation(
                    fileID: spec.location.fileID,
                    filePath: spec.location.filePath,
                    line: spec.location.line,
                    column: spec.location.column
                )
            )
        },
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}

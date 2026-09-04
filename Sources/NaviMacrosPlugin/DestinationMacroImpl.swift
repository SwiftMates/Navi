//
//  DestinationMacroImpl.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 21..
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct DestinationRepresentableMacro: MemberMacro, ExtensionMacro {

    // MARK: - MemberMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: declaration, message: NaviDiagnostic.notAnEnum))
            return []
        }

        let enumName = enumDecl.name

        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }

        // A caseless enum has nothing to switch over; generating an empty
        // `navigationOrigin` would be meaningless, so diagnose instead.
        guard elements.isEmpty == false else {
            context.diagnose(Diagnostic(node: enumDecl.name, message: NaviDiagnostic.noCases))
            return []
        }

        let casesWithOriginKey = caseDecls.filter { $0.hasAttribute(named: "OriginKey") }
        let originCaseElements = casesWithOriginKey.flatMap { $0.elements }

        // Static stored properties are disallowed in generic types (and in types nested
        // inside them), so a generic enum can't host the `Origins` enum's origin keys.
        if enumDecl.genericParameterClause != nil, casesWithOriginKey.isEmpty == false {
            for caseDecl in casesWithOriginKey {
                context.diagnose(
                    Diagnostic(node: caseDecl, message: NaviDiagnostic.originKeyInGenericEnum))
            }
            return []
        }

        // Drop cases whose names aren't valid identifiers after suffixing.
        var originCases: [EnumCaseElementSyntax] = []
        for element in originCaseElements {
            guard isValidSwiftIdentifier(element.canonicalName) else {
                context.diagnose(
                    Diagnostic(node: element, message: NaviDiagnostic.originKeyRawIdentifier))
                continue
            }
            originCases.append(element)
        }
        let originCaseNameSet = Set(originCases.map { $0.name.text })

        // MARK: navigationOrigin on the parent enum

        let navigationOriginProperty = try VariableDeclSyntax(
            "var navigationOrigin: (any OriginRepresentable)?"
        ) {
            try SwitchExprSyntax("switch self") {
                for caseName in elements {
                    let name = caseName.name.text
                    if originCaseNameSet.contains(name) {
                        SwitchCaseSyntax(
                            "case .\(raw: name): return Origins.\(raw: caseName.canonicalName)")
                    } else {
                        SwitchCaseSyntax("case .\(raw: name): return nil")
                    }
                }
            }
        }

        // If nothing is marked, we're done — no nested Origins enum needed.
        guard originCases.isEmpty == false else {
            return [DeclSyntax(navigationOriginProperty)]
        }

        // MARK: nested Origins enum

        let originsEnumCases = try MemberBlockItemListSyntax {
            // case <case>
            for element in originCases {
                try EnumCaseDeclSyntax("case \(raw: element.name.text)")
            }

            // var key: NavigationOriginKey { switch self { … } }
            try VariableDeclSyntax("var key: NavigationOriginKey") {
                try SwitchExprSyntax("switch self") {
                    for element in originCases {
                        SwitchCaseSyntax(
                            "case .\(raw: element.name.text): Self.\(raw: element.canonicalName)OriginKey"
                        )
                    }
                }
            }

            // static private let <case>OriginKey = NavigationOriginKey(debugName: "<Enum> - <case> Origin")
            for element in originCases {
                let base = element.canonicalName
                try VariableDeclSyntax(
                    #"static private let \#(raw: base)OriginKey = NavigationOriginKey(debugName: "\#(raw: enumName.text) - \#(raw: base) Origin")"#
                )
            }
        }

        let originsEnum = try EnumDeclSyntax("enum Origins: OriginRepresentable") {
            originsEnumCases
        }

        return [DeclSyntax(navigationOriginProperty), DeclSyntax(originsEnum)]
    }

    // MARK: - Helpers

    /// Whether `text` is a valid Swift identifier — used to reject raw-identifier case
    /// names (e.g. `my case`) whose generated `…Origin` key would not compile.
    private static func isValidSwiftIdentifier(_ text: String) -> Bool {
        guard let first = text.first, first == "_" || first.isLetter else { return false }
        return text.dropFirst().allSatisfy { $0 == "_" || $0.isLetter || $0.isNumber }
    }

    // MARK: - ExtensionMacro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            // The member-macro role already emitted the diagnostic; stay silent
            // here so a non-enum produces exactly one error, not two.
            return []
        }

        // Honor the extension-macro contract: the compiler passes only the protocols the
        // type does not already declare, so an empty list means there is nothing to add.
        // Bail rather than emit a redundant `extension … : DestinationRepresentable`.
        guard protocols.isEmpty == false else { return [] }

        let genericParameters = enumDecl.genericParameterClause?.parameters ?? []

        // Constrain each generic parameter to Hashable, otherwise the
        // Hashable-refining DestinationRepresentable conformance fails to compile
        // for a generic enum whose parameter isn't already Hashable. `nil` when
        // the enum is non-generic, preserving the current output.
        let whereClause: GenericWhereClauseSyntax? =
            genericParameters.isEmpty
            ? nil
            : GenericWhereClauseSyntax {
                for parameter in genericParameters {
                    GenericRequirementSyntax(
                        requirement: .conformanceRequirement(
                            ConformanceRequirementSyntax(
                                leftType: IdentifierTypeSyntax(name: parameter.name),
                                rightType: IdentifierTypeSyntax(name: .identifier("Hashable"))
                            )
                        )
                    )
                }
            }

        // `extendedType: type` handles nested enums automatically
        // e.g. <Outer>.<Enum> instead of just <Enum>
        let conformanceExtension = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax("DestinationRepresentable"))
            },
            genericWhereClause: whereClause
        ) {}

        return [conformanceExtension]
    }
}

// MARK: - OriginKeyMacro

public struct OriginKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Must be applied to an enum case
        guard declaration.is(EnumCaseDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: declaration, message: NaviDiagnostic.notAnEnumCase))
            return []
        }

        // No code generation is needed
        // It is only a marker for the @DestinationRepresentable macro
        return []
    }
}

// MARK: - Syntax Helpers

extension EnumCaseElementSyntax {
    /// Case name with surrounding backticks removed (keyword-safe): `default` → "default".
    fileprivate var canonicalName: String { name.identifier?.name ?? name.text }
}

extension EnumCaseDeclSyntax {
    /// Whether this case declaration carries the attribute written as `@<name>`.
    fileprivate func hasAttribute(named name: String) -> Bool {
        attributes.contains { element in
            element.as(AttributeSyntax.self)?
                .attributeName
                .as(IdentifierTypeSyntax.self)?
                .name.text == name
        }
    }
}

// MARK: - Diagnostics

enum NaviDiagnostic: String, DiagnosticMessage {
    case notAnEnum
    case notAnEnumCase
    case originKeyInGenericEnum
    case originKeyRawIdentifier
    case noCases

    var message: String {
        switch self {
        case .notAnEnum: "@DestinationRepresentable can only be applied to an enum"
        case .noCases:
            "@DestinationRepresentable can only be applied to an enum with at least one case"
        case .notAnEnumCase: "@OriginKey can only be applied to an enum case"
        case .originKeyInGenericEnum:
            "@OriginKey is not supported on a case of a generic enum, because its generated origin key would be a static stored property, which Swift does not allow in generic types"
        case .originKeyRawIdentifier:
            "@OriginKey is not supported on a case whose name is a raw identifier, because the generated origin key would not be a valid Swift identifier"
        }
    }

    var diagnosticID: MessageID { MessageID(domain: "NaviMacros", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
}

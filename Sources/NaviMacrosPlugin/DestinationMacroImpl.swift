//
//  DestinationMacroImpl.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 21..
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

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

        // Only cases marked with @OriginKey get a static key
        let casesWithOriginKey = caseDecls.filter { $0.hasAttribute(named: "OriginKey") }

        let originCaseNames = casesWithOriginKey.flatMap { $0.elements }

        // A generic enum cannot declare the `static let …Origin` stored properties that
        // @OriginKey requires — Swift disallows static stored properties in generic types.
        // Diagnose (one error per offending case) instead of emitting code that can't compile.
        if enumDecl.genericParameterClause != nil, casesWithOriginKey.isEmpty == false {
            for caseDecl in casesWithOriginKey {
                context.diagnose(Diagnostic(node: caseDecl, message: NaviDiagnostic.originKeyInGenericEnum))
            }
            return []
        }

        // @OriginKey needs a case name that stays a valid identifier once suffixed with
        // "Origin". A raw identifier (e.g. `my case`) would not, so diagnose and drop it
        // rather than emit uncompilable code; the remaining cases still expand normally.
        var originCases: [EnumCaseElementSyntax] = []
        for element in originCaseNames {
            guard isValidSwiftIdentifier(element.canonicalName) else {
                context.diagnose(Diagnostic(node: element, message: NaviDiagnostic.originKeyRawIdentifier))
                continue
            }
            originCases.append(element)
        }
        let originCaseNameSet = Set(originCases.map { $0.name.text })

        let navigationOriginProperty = try VariableDeclSyntax("var navigationOrigin: NavigationOriginKey?") {
            try SwitchExprSyntax("switch self") {
                for caseName in elements {
                    // `.text` is the bare token text (no trivia), keeping backticks; using it
                    // for the label avoids the stray space a raw-value assignment
                    // (`case destination = "…"`) would otherwise leak into `case .destination :`.
                    let name = caseName.name.text
                    if originCaseNameSet.contains(name) {
                        // `canonicalName` drops surrounding backticks so a keyword-named
                        // case (e.g. `default`) yields a valid identifier like `defaultOrigin`.
                        SwitchCaseSyntax("case .\(raw: name): return Self.\(raw: caseName.canonicalName)Origin")
                    } else {
                        SwitchCaseSyntax("case .\(raw: name): return nil")
                    }
                }
            }
        }


        let navigationDestinationKeys = try originCases.map { element -> DeclSyntax in
            let base = element.canonicalName
            return DeclSyntax(
                try VariableDeclSyntax(
                    """
                        static let \(raw: base)Origin = NavigationOriginKey(debugName: "\(raw: enumName.text) - \(raw: base) Origin")
                    """
                )
            )
        }

        return [DeclSyntax(navigationOriginProperty)] + navigationDestinationKeys
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
        let whereClause: GenericWhereClauseSyntax? = genericParameters.isEmpty
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
        // e.g. Container.Destination instead of just Destination
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

private extension EnumCaseElementSyntax {
    /// Case name with surrounding backticks removed (keyword-safe): `default` → "default".
    var canonicalName: String { name.identifier?.name ?? name.text }
}

private extension EnumCaseDeclSyntax {
    /// Whether this case declaration carries the attribute written as `@<name>`.
    func hasAttribute(named name: String) -> Bool {
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

    var message: String {
        switch self {
        case .notAnEnum: "@DestinationRepresentable can only be applied to an enum"
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

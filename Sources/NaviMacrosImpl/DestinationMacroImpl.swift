//
//  DestinationMacroImpl.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 21..
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct DestinationMacro: MemberMacro, ExtensionMacro {

    // MARK: - MemberMacro
    // Generates the static keys + navigationOrigin property inside the enum

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw DestinationMacroError.notAnEnum
        }

        let enumName = enumDecl.name.text

        let cases = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap { $0.elements }
            .map { $0.name.text }

        // Static NavigationOriginKey lets inside the enum
        let staticKeys: [DeclSyntax] = cases.map { caseName in
            """
            static let \(raw: caseName)Origin = NavigationOriginKey(debugName: "\(raw: enumName) - \(raw: caseName) Origin")
            """
        }

        // Switch cases for navigationOrigin
        let switchCases = cases.map { caseName in
            "        case .\(caseName): return Self.\(caseName)Origin"
        }.joined(separator: "\n")

        let navigationOriginProperty: DeclSyntax = """
        public var navigationOrigin: NavigationOriginKey {
            switch self {
        \(raw: switchCases)
            }
        }
        """

        return staticKeys + [navigationOriginProperty]
    }

    // MARK: - ExtensionMacro
    // Only generates the DestinationRepresentable conformance

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw DestinationMacroError.notAnEnum
        }

        let enumName = enumDecl.name.text

        let conformanceExtension: DeclSyntax = """
        extension \(raw: enumName): DestinationRepresentable {}
        """

        guard let conformanceSyntax = conformanceExtension.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [conformanceSyntax]
    }
}

// MARK: - Error

enum DestinationMacroError: Error, CustomStringConvertible {
    case notAnEnum

    var description: String {
        switch self {
        case .notAnEnum:
            return "@Destination can only be applied to an enum"
        }
    }
}

// MARK: - Plugin

@main
struct NaviPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DestinationMacro.self
    ]
}

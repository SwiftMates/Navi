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

        let allCases = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap { $0.elements }

        // All cases for the switch statement
        let allCaseNames = allCases.map { $0.name.text }

        // Only cases marked with @Origin get a static key
        let originCases = enumDecl.memberBlock.members
            .compactMap { member -> EnumCaseDeclSyntax? in
                guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { return nil }
                let hasOrigin = member.decl.as(EnumCaseDeclSyntax.self)?
                    .attributes
                    .contains { attribute in
                        attribute.as(AttributeSyntax.self)?
                            .attributeName
                            .as(IdentifierTypeSyntax.self)?
                            .name.text == "Origin"
                    } ?? false
                return hasOrigin ? caseDecl : nil
            }
            .flatMap { $0.elements }
            .map { $0.name.text }

        // Generate static keys only for @Origin marked cases
        let staticKeys: [DeclSyntax] = originCases.map { caseName in
            """
            static let \(raw: caseName)Origin = NavigationOriginKey(debugName: "\(raw: enumName) - \(raw: caseName) Origin")
            """
        }

        // Generate switch with all cases, only @Origin cases return a key
        let switchCases = allCaseNames.map { caseName in
            if originCases.contains(caseName) {
                return "        case .\(caseName): return Self.\(caseName)Origin"
            } else {
                return "        case .\(caseName): return nil"
            }
        }.joined(separator: "\n")

        let navigationOriginProperty: DeclSyntax = """
        public var navigationOrigin: NavigationOriginKey? {
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

// MARK: - Origin Mark

public struct OriginMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Must be applied to an enum case
        guard declaration.is(EnumCaseDeclSyntax.self) else {
            throw OriginMacroError.notAnEnumCase
        }
        
        return []
    }
}

enum OriginMacroError: Error, CustomStringConvertible {
    case notAnEnumCase

    var description: String {
        switch self {
        case .notAnEnumCase:
            return "@Origin can only be applied to an enum case"
        }
    }
}

// MARK: - Plugin

@main
struct NaviPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DestinationMacro.self,
        OriginMacro.self
    ]
}

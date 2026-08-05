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
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw DestinationRepresentableMacroError.notAnEnum
        }

        let enumName = enumDecl.name

        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }

        // Only cases marked with @OriginKey get a static key
        let casesWithOriginKey = caseDecls.filter { caseDcl in
            caseDcl.attributes.contains { attribute in
                attribute.as(AttributeSyntax.self)?
                    .attributeName
                    .as(IdentifierTypeSyntax.self)?
                    .name.text == "OriginKey"
            }
        }

        let originCaseNames = casesWithOriginKey.flatMap { $0.elements }

        let navigationOriginProperty = try VariableDeclSyntax("public var navigationOrigin: NavigationOriginKey?") {
            try SwitchExprSyntax("switch self") {
                for caseName in elements {
                    if originCaseNames.contains(caseName) {
                        SwitchCaseSyntax("case .\(caseName.name): return Self.\(caseName.name)Origin")
                    } else {
                        SwitchCaseSyntax("case .\(caseName.name): return nil")
                    }
                }
            }
        }


        var navigationDestinationKeys: [DeclSyntax] = []

        for caseName in originCaseNames {
            let keyDeclaration = try VariableDeclSyntax(
                """
                    static let \(caseName.name)Origin = NavigationOriginKey(debugName: "\(raw: enumName.text) - \(caseName.name) Origin")
                """
            )
            navigationDestinationKeys.append(DeclSyntax(keyDeclaration))
        }

        return [DeclSyntax(navigationOriginProperty)] + navigationDestinationKeys

        //        let allCases = enumDecl.memberBlock.members
        //            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        //            .flatMap { $0.elements }
        //
        //        let allCaseNames = allCases.map { $0.name.text }
        //
        //        // Only cases marked with @OriginKey get a static key
        //        let originCaseNames = enumDecl.memberBlock.members
        //            .compactMap { member -> EnumCaseDeclSyntax? in
        //                guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { return nil }
        //                let hasOrigin = caseDecl.attributes.contains { attribute in
        //                    attribute.as(AttributeSyntax.self)?
        //                        .attributeName
        //                        .as(IdentifierTypeSyntax.self)?
        //                        .name.text == "OriginKey"
        //                }
        //                return hasOrigin ? caseDecl : nil
        //            }
        //            .flatMap { $0.elements }
        //            .map { $0.name.text }
        //
        //        // Generate static NavigationOriginKey only for @OriginKey marked cases
        //        let staticKeys: [DeclSyntax] = originCaseNames.map { caseName in
        //            """
        //            static let \(raw: caseName)Origin = NavigationOriginKey(debugName: "\(raw: enumName) - \(raw: caseName) Origin")
        //            """
        //        }
        //
        //        // Generate switch with all cases
        //        // @OriginKey cases return their key, others return nil
        //        let switchCases = allCaseNames.map { caseName in
        //            if originCaseNames.contains(caseName) {
        //                return "        case .\(caseName): return Self.\(caseName)Origin"
        //            } else {
        //                return "        case .\(caseName): return nil"
        //            }
        //        }.joined(separator: "\n")
        //
        //        let navigationOriginProperty: DeclSyntax = """
        //        public var navigationOrigin: NavigationOriginKey? {
        //            switch self {
        //        \(raw: switchCases)
        //            }
        //        }
        //        """
        //
        //        return staticKeys + [navigationOriginProperty]
    }

    // MARK: - ExtensionMacro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        guard declaration.is(EnumDeclSyntax.self) else {
            throw DestinationRepresentableMacroError.notAnEnum
        }

        // Using `type` directly handles nested enums automatically
        // e.g. HomeFlowCoordinator.Destination instead of just Destination
        let conformanceExtension: DeclSyntax = """
        extension \(type): DestinationRepresentable {}
        """

        guard let conformanceSyntax = conformanceExtension.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [conformanceSyntax]
    }
}

// MARK: - Error

public enum DestinationRepresentableMacroError: Error, CustomStringConvertible {
    case notAnEnum

    public var description: String {
        switch self {
        case .notAnEnum:
            return "@DestinationRepresentable can only be applied to an enum"
        }
    }
}

// MARK: - Origin Mark

public struct OriginKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Must be applied to an enum case
        guard declaration.is(EnumCaseDeclSyntax.self) else {
            throw OriginKeyMacroError.notAnEnumCase
        }

        // No code generation is needed
        // It is only a marker for the @DestinationRepresentable macro
        return []
    }
}

public enum OriginKeyMacroError: Error, CustomStringConvertible {
    case notAnEnumCase

    public var description: String {
        switch self {
        case .notAnEnumCase:
            return "@OriginKey can only be applied to an enum case"
        }
    }
}

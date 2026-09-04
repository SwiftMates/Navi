//
//  NaviPlugin.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 22..
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct NaviPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DestinationRepresentableMacro.self,
        OriginKeyMacro.self,
    ]
}

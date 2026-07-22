//
//  DestinationMacro.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 21..
//

@attached(member, names: named(navigationOrigin), arbitrary)
@attached(extension, conformances: DestinationRepresentable)
public macro DestinationRepresentable() = #externalMacro(
    module: "NaviMacrosImpl",
    type: "DestinationRepresentableMacro"
)

@attached(peer)
public macro OriginKey() = #externalMacro(
    module: "NaviMacrosImpl",
    type: "OriginKeyMacro"
)

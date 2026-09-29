//
//  DestinationMacro.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 21..
//

@attached(member, names: named(navigationOrigin), named(Origins))
@attached(extension, conformances: DestinationRepresentable)
public macro DestinationRepresentable() =
    #externalMacro(
        module: "NaviMacrosPlugin",
        type: "DestinationRepresentableMacro"
    )

@attached(peer)
public macro OriginKey() =
    #externalMacro(
        module: "NaviMacrosPlugin",
        type: "OriginKeyMacro"
    )

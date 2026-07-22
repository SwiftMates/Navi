//
//  DestinationMacro.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 21..
//

// TODO: - Rename to @DestinationRepresentable

@attached(member, names: named(navigationOrigin), arbitrary)
@attached(extension, conformances: DestinationRepresentable)
public macro Destination() = #externalMacro(
    module: "NaviMacrosImpl",
    type: "DestinationMacro"
)

// TODO: - Rename to @OriginKey

@attached(peer)
public macro Origin() = #externalMacro(
    module: "NaviMacrosImpl",
    type: "OriginMacro"
)

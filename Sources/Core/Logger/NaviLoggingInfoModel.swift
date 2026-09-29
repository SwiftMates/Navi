//
//  NaviLoggingInfoModel.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 27/09/2026.
//

public struct NaviLoggingInfoModel {
    // MARK: - Nested types

    struct RawData {
        var destination: (any DestinationRepresentable)?
        var origin: (any OriginRepresentable)?
        let pathCount: Int
    }

    // MARK: - Public properties

    let message: String    
    let rawData: RawData
}

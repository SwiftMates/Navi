//
//  NaviLoggingInfoModel.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 27/09/2026.
//

public struct NaviLoggingInfoModel {
    struct RawData {
        let destination: any DestinationRepresentable
        let origin: (any OriginRepresentable)?
        let pathCount: Int
    }

    let message: String
    
    let rawData: RawData
}

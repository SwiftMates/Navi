//
//  NaviLoggingInfoModel.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 27/09/2026.
//

public struct NaviLoggingInfoModel<D: DestinationRepresentable, O: OriginRepresentable> {
    struct RawData {
        let destination: D
        let origin: O?
        let pathCount: Int
    }

    let message: String
    
    let rawData: RawData
}

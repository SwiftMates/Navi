//
//  NaviLoggingInfoModel.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 27/09/2026.
//

struct NaviLoggingInfoModel<D: DestinationRepresentable, O: OriginRepresentable> {
    struct RawData {
        let destination: D
        let origin: OriginRepresentable
        let pathCount: Int
    }

    let message: String
    
    let rawData: RawData
}

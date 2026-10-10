//
//  NaviLoggingInfoModel.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 27/09/2026.
//

public struct NaviLoggingInfoModel {
    // MARK: - Nested types

    public struct RawData {
        public var destination: (any DestinationRepresentable)?
        public var origin: (any OriginRepresentable)?
        public let pathCount: Int
    }

    // MARK: - Public properties

    public let message: String
    public let rawData: RawData
}

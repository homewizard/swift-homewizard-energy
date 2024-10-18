//
//  P1ExternalDataType.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 08/10/2024.
//

import Foundation

/**
 # P1ExternalDataType

 Some smart meters have more than one external device connected to it.
 This can be, for example, a gas and a water meter.

 This will describe the type of the external connected device

 > Note:
 This will support all known types for the current version of this package.
 In case new devices are available that aren't supported by this version yet,
 the type will be `.unknown` with the raw value of the new type.

 */
public enum P1ExternalDataType: Codable, Equatable, CaseIterable, Sendable {
    public typealias RawValue = String

    /// Gas Meter
    case gasMeter
    /// Heat meter
    case heatMeter
    /// Water meter
    case waterMeter
    /// Warm Water meter
    case warmWaterMeter
    /// Inlet Heat meter
    case inletHeatMeter

    /// Unknown (future device type which is not yet supported by this package version)
    case unknown(rawValue: String)

    public static let allCases: [Self] = [
        .gasMeter,
        .heatMeter,
        .waterMeter,
        .warmWaterMeter,
        .inletHeatMeter
    ]

    public init?(rawValue: String) {
        if let type = Self.allCases.first(where: { $0.rawValue == rawValue }) {
            self = type

        } else {
            self = .unknown(rawValue: rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .gasMeter:
            return "gas_meter"
        case .heatMeter:
            return "heat_meter"
        case .waterMeter:
            return "water_meter"
        case .warmWaterMeter:
            return "warm_water_meter"
        case .inletHeatMeter:
            return "inlet_heat_meter"

        case .unknown(let rawValue):
            return rawValue
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        self = .init(rawValue: rawValue)!
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

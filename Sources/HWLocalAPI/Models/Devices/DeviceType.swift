//
//  DeviceType.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 04/10/2024.
//

import Foundation

/**
 # DeviceType

 The type of a HomeWizard device.

 > Note:
 This will support all known devices for the current version of this package.
 In case new devices are available that aren't supported by this version yet,
 the type will be `.unknown` with the raw value of the new type.

 */
public enum DeviceType: Codable, Equatable, CaseIterable, Sendable {
    public typealias RawValue = String

    /// P1 Meter
    case p1Meter
    /// Energy Socket
    case energySocket
    /// Watermeter
    case watermeter
    /// HomeWizard kWh Meter - 1 phase
    case kwhMeter1Phase
    /// HomeWizard kWh Meter - 3 phases
    case kwhMeter3Phase
    /// Eastron kWh Meter - 1 phase
    case kwhMeter1PhaseEastron
    /// Eastron kWh Meter - 3 phases
    case kwhMeter3PhaseEastron

    /// Unknown (future device type which is not yet supported by this package version)
    case unknown(rawValue: String)

    public static let allCases: [Self] = [
        .p1Meter,
        .energySocket,
        .watermeter,
        .kwhMeter1Phase,
        .kwhMeter3Phase,
        .kwhMeter1PhaseEastron,
        .kwhMeter3PhaseEastron
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
        case .p1Meter:
            return "HWE-P1"
        case .energySocket:
            return "HWE-SKT"
        case .watermeter:
            return "HWE-WTR"
        case .kwhMeter1Phase:
            return "HWE-KWH1"
        case .kwhMeter3Phase:
            return "HWE-KWH3"
        case .kwhMeter1PhaseEastron:
            return "SDM230-wifi"
        case .kwhMeter3PhaseEastron:
            return "SDM630-wifi"

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

// MARK: - Internal Helpers

extension DeviceType {
    /// Maps a `DeviceType` to its specific `Device` struct
    internal var typeName: (any InternalDevice.Type) {
        switch self {
        case .p1Meter:
            P1Meter.self
        case .energySocket:
            EnergySocket.self
        case .watermeter:
            Watermeter.self
        case .kwhMeter1Phase,
                .kwhMeter3Phase,
                .kwhMeter1PhaseEastron,
                .kwhMeter3PhaseEastron:
            KwhMeter.self
        case .unknown:
            UnknownDevice.self
        }
    }

    internal var dataName: (any DeviceData.Type)? {
        switch self {
        case .p1Meter:
            P1MeterData.self
        case .energySocket:
            EnergySocketData.self
        case .watermeter:
            WatermeterData.self
        case .kwhMeter1Phase,
                .kwhMeter3Phase,
                .kwhMeter1PhaseEastron,
                .kwhMeter3PhaseEastron:
            KwhMeterData.self
        case .unknown:
            nil
        }
    }
}

//
//  P1ExternalData.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 08/10/2024.
//

import Foundation

/**
 # P1ExternalData

 Some smart meters have more than one external device connected to it.
 This can be, for example, a gas and a water meter.

 Each entry will be available as a single `P1ExternalData` instance.

 > Note:
 Time stamps of these devices are in the local time zone of the smart meter.
 The default property ``timestamp`` is in the local time zone of the device running this code.
 You may use ``timestamp(in:)`` to get it in a specific time zone.

 */
public struct P1ExternalData: Codable, Sendable {
    /// The unique identifier from this device
    public let uniqueId: String?

    /// The type of the external device
    public let type: P1ExternalDataType?

    /// The most recent value update time stamp as API Timestamp
    private let _timestamp: UInt?
    /**
     The most recent value update time stamp

     > Note:
     Time stamps of these devices are in the local time zone of the smart meter.
     The default property ``timestamp`` is in the local time zone of the device running this code.
     You may use ``timestamp(in:)`` to get it in a specific time zone.

     */
    public var timestamp: Date? {
        Date(apiTimestamp: _timestamp)
    }

    /// The raw value
    public let value: Double?

    /// The unit of the value (e.g. "m3" or "GJ")
    public let unit: String?

    private enum CodingKeys: String, CodingKey {
        case uniqueId = "unique_id"
        case type
        case _timestamp = "timestamp"
        case value
        case unit
    }

    /**
     The most recent value update time stamp within the specified time zone

     - parameter zone: The time zone to use
     - returns: The time stamp within the specified zone
     */
    public func timestamp(in zone: TimeZone) -> Date? {
        Date(apiTimestamp: _timestamp, in: zone)
    }
}


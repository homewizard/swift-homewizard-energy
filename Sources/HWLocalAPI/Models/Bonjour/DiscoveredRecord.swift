//
//  DiscoveredRecord.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 09/10/2024.
//

#if !os(Linux)

import Foundation

/**
 # DiscoveredRecord

 The Bonjour TXT record retrieved with the discovery
 */
internal struct DiscoveredRecord: Decodable, Sendable {
    /// Human-friendly name for the device
    let name: String
    /// Type of the device
    let type: DeviceType
    /// The device's serial/mac address
    let serial: Serial
    /// Path to the API
    let path: String
    /// Whether the local API is enabled on this device
    let isAPIEnabled: Bool

    private enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case type = "product_type"
        case serial
        case path
        case isAPIEnabled = "api_enabled"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(DeviceType.self, forKey: .type)
        serial = try container.decode(String.self, forKey: .serial)
        path = try container.decode(String.self, forKey: .path)

        let boolStr = try container.decode(String.self, forKey: .isAPIEnabled)
        isAPIEnabled = boolStr == "1"
    }
}

#endif

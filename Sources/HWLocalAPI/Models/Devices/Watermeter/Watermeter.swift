//
//  Watermeter.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 04/10/2024.
//

import Foundation

// MARK: - Watermeter

/**
 # Watermeter

 A HomeWizard watermeter

 ## Usage

 The latest measurement data can be fetched using ``fetchData()``, which will return ``WatermeterData``.

 */
public struct Watermeter: InternalDevice, IdentifiableDevice {
    public let name: String
    public let type: DeviceType
    public let serial: Serial
    public let firmwareVersion: String
    public let apiVersion: String

    internal(set) public var baseURL: String?

    private enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case type = "product_type"
        case serial
        case firmwareVersion = "firmware_version"
        case apiVersion = "api_version"
    }
}

// MARK: Data fetching

extension Watermeter {
    /**
     Fetches the most recent measurement from the device.

     - returns: The most recent measurement data of this meter
     - throws
     */
    public func fetchData() async throws -> WatermeterData {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }

        let manager = RequestManager(baseURL: baseURL)
        return try await manager
            .performRequest(
                "/api/\(apiVersion)/data",
                method: .get
            )
    }
}

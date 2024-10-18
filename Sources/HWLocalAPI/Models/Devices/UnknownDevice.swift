//
//  UnknownDevice.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 04/10/2024.
//

import Foundation

/**
 # UnknownDevice

 A future HomeWizard device that is not yet supported by
 this version of this package.

 ## Measurement Data

 Since we don't know anything about this device at this time,
 we won't be able to give a nice, parsed measurement data object for it.

 Since most of HomeWizard's devices will probably support some kind of
 measurement data, you could try if ``fetchData()`` succeeds and get
 the raw JSON data of it.

 */
public struct UnknownDevice: InternalDevice {
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

extension UnknownDevice {
    /**
     Tries to fetch the most recent measurement from this unknown device.

     - returns: The retrieved data as JSON
     - throws
     */
    public func fetchData() async throws -> JSON {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }

        let manager = RequestManager(baseURL: baseURL)
        return try await manager
            .performJSONRequest(
                "/api/\(apiVersion)/data",
                json: nil,
                method: .get
            )
    }
}

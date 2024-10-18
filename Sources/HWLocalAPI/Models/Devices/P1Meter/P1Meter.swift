
import Foundation

// MARK: - P1 Meter

/**
 # P1Meter

 A HomeWizard P1 Meter

 ## Usage

 Besides the regular data (``P1MeterData``) like all other devices have as well,
 the P1 meter can also give the last received telegram.

 ### Meter Data

 To get the latest measurement data of a P1 meter, you can use ``fetchData()``.

 ### Telegram

 To get the last telegram from the smart meter, you can use ``fetchTelegram()``

 > Note:
 The telegram validated with its CRC, but is not parsed in any form.

 */
public struct P1Meter: InternalDevice, IdentifiableDevice {
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

extension P1Meter {
    /**
     Fetches the most recent measurement from the device.

     - returns: The most recent measurement data of this meter
     - throws
     */
    public func fetchData() async throws -> P1MeterData {
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

    /**
     Fetches the last telegram from the smart meter

     > Note:
     The telegram validated with its CRC, but is not parsed in any form.

     - returns: The last telegram in plain text
     - throws
     */
    public func fetchTelegram() async throws -> String? {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }
        
        let manager = RequestManager(baseURL: baseURL)
        let data: Data = try await manager
            .performRequest(
                "/api/\(apiVersion)/telegram",
                method: .get
            )

        return String(data: data, encoding: .utf8)
    }
}

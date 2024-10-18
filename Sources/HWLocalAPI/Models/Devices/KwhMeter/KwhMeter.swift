
import Foundation

// MARK: - kWh Meter

/**
 # KwhMeter

 A HomeWizard (or Eastron) kWh Meter

 ## Usage

 The latest measurement data can be fetched using ``fetchData()``, which will return ``KwhMeterData``.

 */

public struct KwhMeter: InternalDevice {
    /**
     The appearance of this device.

     Either the first gen Eastron meter, or the next gen HomeWizard meter
     */
    public enum Appearance: String, Codable, Sendable {
        case homeWizard
        case eastron
    }

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

extension KwhMeter {
    /// The number of phases of this kWh meter
    public var numberOfPhases: Int {
        switch type {
        case .kwhMeter1Phase,
                .kwhMeter1PhaseEastron:
            return 1

        case .kwhMeter3Phase,
                .kwhMeter3PhaseEastron:
            return 3

        default:
            return 0
        }
    }

    /// The appearance of this kWh meter
    public var appearance: Appearance {
        [.kwhMeter1PhaseEastron, .kwhMeter3PhaseEastron].contains(type)
            ? .eastron
            : .homeWizard
    }
}

// MARK: Data fetching

extension KwhMeter {
    /**
     Fetches the most recent measurement from the device

     - returns: The most recent measurement data from this meter
     - throws
     */
    public func fetchData() async throws -> KwhMeterData {
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

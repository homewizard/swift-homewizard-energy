
import Foundation

/**
 # EnergySocketData

 Data points for the ``EnergySocket``

 */
public struct EnergySocketData: Codable, Sendable, DeviceData {
    // MARK: - Data Properties

    /// The Wi-Fi network that the meter is connected to
    public let wifiSSID: String
    /// The strength of the Wi-Fi signal in %
    public let wifiStrength: Int

    /// The energy usage meter reading in kWh
    public let totalPowerImport: Double?
    /// The energy feed-in meter reading in kWh
    public let totalPowerExport: Double?

    /// The total active usage in watt
    public let activePower: Double?
    /// The total active voltage in volt
    public let activeVoltage: Double?
    /// The total active current in ampere
    public let activeCurrent: Double?

    /**
     The reactive power in volt-amperes reactive (var)

     > Note:
     Only available for the `HWE-SKT-21` model
     */
    public let activeReactivePower: Double?
    /**
     The apparent power in volt-amperes (va)

     > Note:
     Only available for the `HWE-SKT-21` model
     */
    public let activeApparentPower: Double?
    /**
     The power factor

     > Note:
     Only available for the `HWE-SKT-21` model
     */
    public let activePowerFactor: Double?

    /// The active line frequency in hertz
    public let activeFrequency: Double?

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case wifiSSID = "wifi_ssid"
        case wifiStrength = "wifi_strength"
        case totalPowerImport = "total_power_import_kwh"
        case totalPowerExport = "total_power_export_kwh"
        case activePower = "active_power_w"
        case activeVoltage = "active_voltage_v"
        case activeCurrent = "active_current_a"
        case activeReactivePower = "active_reactive_power_var"
        case activeApparentPower = "active_apparent_power_va"
        case activePowerFactor = "active_power_factor"
        case activeFrequency = "active_frequency_hz"
    }
}

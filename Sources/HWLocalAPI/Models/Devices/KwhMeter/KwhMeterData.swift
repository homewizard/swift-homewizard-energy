
import Foundation

/**
 # KwhMeterData

 Data points for the ``KwhMeter``
 
 */
public struct KwhMeterData: Codable, Sendable, DeviceData {
    // MARK: - kWh Meter Data Properties

    // MARK: Wi-Fi info

    /// The Wi-Fi network that the meter is connected to
    public let wifiSSID: String
    /// The strength of the Wi-Fi signal in %
    public let wifiStrength: Int

    // MARK: Energy Totals

    /// The energy usage meter reading for all tariffs in kWh
    public let totalPowerImport: Double?
    /// The energy feed-in meter reading for all tariffs in kWh
    public let totalPowerExport: Double?

    // MARK: Active Measurements

    /**
     The total active usage in watt
     */
    public let activePower: Double?
    /**
     The active usage for phase 1 in watt
     */
    public let activePowerL1: Double?
    /**
     The active usage for phase 2 in watt

     > Note:
     Only available for the 3 phase meter
     */
    public let activePowerL2: Double?
    /**
     The active usage for phase 3 in watt

     > Note:
     Only available for the 3 phase meter
     */
    public let activePowerL3: Double?

    /**
     The active voltage in volt

     > Note:
     Only available for the 1 phase meter
     */
    public let activeVoltage: Double?
    /**
     The active voltage for phase 1 in volt

     > Note:
     Only available for the 3 phase meter
     */
    public let activeVoltageL1: Double?
    /**
     The active voltage for phase 2 in volt

     > Note:
     Only available for the 3 phase meter
     */
    public let activeVoltageL2: Double?
    /**
     The active voltage for phase 3 in volt

     > Note:
     Only available for the 3 phase meter
     */
    public let activeVoltageL3: Double?

    /**
     The total active current in ampere
     */
    public let activeCurrent: Double?
    /**
     The active current for phase 1 in ampere

     > Note:
     Only available for the 3 phase meter
     */
    public let activeCurrentL1: Double?
    /**
     The active current for phase 2 in ampere

     > Note:
     Only available for the 3 phase meter
     */
    public let activeCurrentL2: Double?
    /**
     The active current for phase 3 in ampere

     > Note:
     Only available for the 3 phase meter
     */
    public let activeCurrentL3: Double?

    /**
     The total apparent current in amperes
     */
    public let activeApparentCurrent: Double?
    /**
     The apparent current for phase 1 in amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeApparentCurrentL1: Double?
    /**
     The apparent current for phase 2 in amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeApparentCurrentL2: Double?
    /**
     The apparent current for phase 3 in amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeApparentCurrentL3: Double?

    /**
     The total reactive current in amperes
     */
    public let activeReactiveCurrent: Double?
    /**
     The reactive current for phase 1 in amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeReactiveCurrentL1: Double?
    /**
     The reactive current for phase 2 in amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeReactiveCurrentL2: Double?
    /**
     The reactive current for phase 3 in amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeReactiveCurrentL3: Double?

    /**
     The total apparent power in volt-amperes
     */
    public let activeApparentPower: Double?
    /**
     The apparent power for phase 1 in volt-amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeApparentPowerL1: Double?
    /**
     The apparent power for phase 2 in volt-amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeApparentPowerL2: Double?
    /**
     The apparent power for phase 3 in volt-amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeApparentPowerL3: Double?

    /**
     The total reactive power in volt-amperes
     */
    public let activeReactivePower: Double?
    /**
     The reactive power for phase 1 in volt-amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeReactivePowerL1: Double?
    /**
     The reactive power for phase 2 in volt-amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeReactivePowerL2: Double?
    /**
     The reactive power for phase 3 in volt-amperes

     > Note:
     Only available for the 3 phase meter
     */
    public let activeReactivePowerL3: Double?

    /**
     The power factor

     > Note:
     Only available for the 1 phase meter
     */
    public let activePowerFactor: Double?
    /**
     The power factor for phase 1

     > Note:
     Only available for the 3 phase meter
     */
    public let activePowerFactorL1: Double?
    /**
     The power factor for phase 2

     > Note:
     Only available for the 3 phase meter
     */
    public let activePowerFactorL2: Double?
    /**
     The power factor for phase 3

     > Note:
     Only available for the 3 phase meter
     */
    public let activePowerFactorL3: Double?

    /// The active line frequency in hertz
    public let activeFrequency: Double?


    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case wifiSSID = "wifi_ssid"
        case wifiStrength = "wifi_strength"
        case totalPowerImport = "total_power_import_kwh"
        case totalPowerExport = "total_power_export_kwh"
        case activePower = "active_power_w"
        case activePowerL1 = "active_power_l1_w"
        case activePowerL2 = "active_power_l2_w"
        case activePowerL3 = "active_power_l3_w"
        case activeVoltage = "active_voltage_v"
        case activeVoltageL1 = "active_voltage_l1_v"
        case activeVoltageL2 = "active_voltage_l2_v"
        case activeVoltageL3 = "active_voltage_l3_v"
        case activeCurrent = "active_current_a"
        case activeCurrentL1 = "active_current_l1_a"
        case activeCurrentL2 = "active_current_l2_a"
        case activeCurrentL3 = "active_current_l3_a"
        case activeApparentCurrent = "active_apparent_current_a"
        case activeApparentCurrentL1 = "active_apparent_current_l1_a"
        case activeApparentCurrentL2 = "active_apparent_current_l2_a"
        case activeApparentCurrentL3 = "active_apparent_current_l3_a"
        case activeReactiveCurrent = "active_reactive_current_a"
        case activeReactiveCurrentL1 = "active_reactive_current_l1_a"
        case activeReactiveCurrentL2 = "active_reactive_current_l2_a"
        case activeReactiveCurrentL3 = "active_reactive_current_l3_a"
        case activeApparentPower = "active_apparent_power_va"
        case activeApparentPowerL1 = "active_apparent_power_l1_va"
        case activeApparentPowerL2 = "active_apparent_power_l2_va"
        case activeApparentPowerL3 = "active_apparent_power_l3_va"
        case activeReactivePower = "active_reactive_power_var"
        case activeReactivePowerL1 = "active_reactive_power_l1_var"
        case activeReactivePowerL2 = "active_reactive_power_l2_var"
        case activeReactivePowerL3 = "active_reactive_power_l3_var"
        case activePowerFactor = "active_power_factor"
        case activePowerFactorL1 = "active_power_factor_l1"
        case activePowerFactorL2 = "active_power_factor_l2"
        case activePowerFactorL3 = "active_power_factor_l3"
        case activeFrequency = "active_frequency_hz"
    }
}

//
//  P1MeterData.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 08/10/2024.
//

import Foundation

/**
 # P1MeterData

 Data points for the ``P1Meter``.

 ## External Devices

 Some smart meters have one or more external device(s) connected to it.
 This can be, for example, a gas meter or a water meter.

 Each of these devices have are listed within ``P1MeterData/externalData``

 ## Belgium Users

 Belgium users are started to get charged for the peak usage per month
 (see [capaciteitstarief](https://www.fluvius.be/nl/thema/factuur-en-tarieven/capaciteitstarief))

 The properties ``P1MeterData/monthlyPowerPeak``, ``P1MeterData/monthlyPowerPeakDate`` and ``P1MeterData/activePowerAverage`` can be
 used to track the maximum demand.

 */
public struct P1MeterData: Codable, Sendable, DeviceData {
    // MARK: - P1 Data Properties

    // MARK: Smart Meter info

    /// The unique identifier from the smart meter
    public let uniqueId: String?
    /// The DSMR version of the smart meter
    public let smrVersion: Int?
    /// The brand identification of the smart meter
    public let meterModel: String?

    // MARK: Wi-Fi info

    /// The Wi-Fi network that the meter is connected to
    public let wifiSSID: String
    /// The strength of the Wi-Fi signal in %
    public let wifiStrength: Int

    // MARK: Energy Totals

    /// The energy usage meter reading for all tariffs in kWh
    public let totalPowerImport: Double?
    /// The energy usage meter reading for tariff 1 in kWh
    public let totalPowerImportT1: Double?
    /// The energy usage meter reading for tariff 2 in kWh
    public let totalPowerImportT2: Double?
    /// The energy usage meter reading for tariff 3 in kWh
    public let totalPowerImportT3: Double?
    /// The energy usage meter reading for tariff 4 in kWh
    public let totalPowerImportT4: Double?

    /// The energy feed-in meter reading for all tariffs in kWh
    public let totalPowerExport: Double?
    /// The energy feed-in meter reading for tariff 1 in kWh
    public let totalPowerExportT1: Double?
    /// The energy feed-in meter reading for tariff 2 in kWh
    public let totalPowerExportT2: Double?
    /// The energy feed-in meter reading for tariff 3 in kWh
    public let totalPowerExportT3: Double?
    /// The energy feed-in meter reading for tariff 4 in kWh
    public let totalPowerExportT4: Double?

    // MARK: Active Measurements

    /// The total active usage in watt
    public let activePower: Double?
    /// The active usage for phase 1 in watt
    public let activePowerL1: Double?
    /// The active usage for phase 2 in watt
    public let activePowerL2: Double?
    /// The active usage for phase 3 in watt
    public let activePowerL3: Double?

    /// The active voltage for phase 1 in volt
    public let activeVoltageL1: Double?
    /// The active voltage for phase 2 in volt
    public let activeVoltageL2: Double?
    /// The active voltage for phase 3 in volt
    public let activeVoltageL3: Double?

    /// The total active current in ampere
    public let activeCurrent: Double?
    /// The active current for phase 1 in ampere
    public let activeCurrentL1: Double?
    /// The active current for phase 2 in ampere
    public let activeCurrentL2: Double?
    /// The active current for phase 3 in ampere
    public let activeCurrentL3: Double?

    /// The active line frequency in hertz
    public let activeFrequency: Double?

    // MARK: Counters

    /// The number of voltage sags detected by meter for phase 1
    public let voltageSagL1: Int?
    /// The number of voltage sags detected by meter for phase 2
    public let voltageSagL2: Int?
    /// The number of voltage sags detected by meter for phase 3
    public let voltageSagL3: Int?

    /// The number of voltage swells detected by meter for phase 1
    public let voltageSwellL1: Int?
    /// The number of voltage swells detected by meter for phase 2
    public let voltageSwellL2: Int?
    /// The number of voltage swells detected by meter for phase 3
    public let voltageSwellL3: Int?

    /// Number of power failures detected by meter
    public let anyPowerFailCount: Int?
    /// Number of 'long' power failures detected by meter
    public let longPowerFailCount: Int?

    // MARK: Monthly Power Peak

    /**
     The active average demand in watt

     Belgium users are started to get charged for the peak usage per month
     (see [capaciteitstarief](https://www.fluvius.be/nl/thema/factuur-en-tarieven/capaciteitstarief))

     The properties ``monthlyPowerPeak``, ``monthlyPowerPeakDate`` and ``activePowerAverage`` can be
     used to track the maximum demand.

     */
    public let activePowerAverage: Double?
    /**
     The peak average demand of this month.

     Belgium users are started to get charged for the peak usage per month
     (see [capaciteitstarief](https://www.fluvius.be/nl/thema/factuur-en-tarieven/capaciteitstarief))

     The properties ``monthlyPowerPeak``, ``monthlyPowerPeakDate`` and ``activePowerAverage`` can be
     used to track the maximum demand.

     */
    public let monthlyPowerPeak: Double?
    /**
     Timestamp when the monthly power peak was registered

     Belgium users are started to get charged for the peak usage per month
     (see [capaciteitstarief](https://www.fluvius.be/nl/thema/factuur-en-tarieven/capaciteitstarief))

     The properties ``monthlyPowerPeak``, ``monthlyPowerPeakDate`` and ``activePowerAverage`` can be
     used to track the maximum demand.

     */
    public let monthlyPowerPeakDate: Date?

    // MARK: External Data

    /// Data of external meters
    public let externalData: [P1ExternalData]

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case uniqueId = "unique_id"
        case smrVersion = "smr_version"
        case meterModel = "meter_model"
        case wifiSSID = "wifi_ssid"
        case wifiStrength = "wifi_strength"
        case totalPowerImport = "total_power_import_kwh"
        case totalPowerImportT1 = "total_power_import_t1_kwh"
        case totalPowerImportT2 = "total_power_import_t2_kwh"
        case totalPowerImportT3 = "total_power_import_t3_kwh"
        case totalPowerImportT4 = "total_power_import_t4_kwh"
        case totalPowerExport = "total_power_export_kwh"
        case totalPowerExportT1 = "total_power_export_t1_kwh"
        case totalPowerExportT2 = "total_power_export_t2_kwh"
        case totalPowerExportT3 = "total_power_export_t3_kwh"
        case totalPowerExportT4 = "total_power_export_t4_kwh"
        case activePower = "active_power_w"
        case activePowerL1 = "active_power_l1_w"
        case activePowerL2 = "active_power_l2_w"
        case activePowerL3 = "active_power_l3_w"
        case activeVoltageL1 = "active_voltage_l1_v"
        case activeVoltageL2 = "active_voltage_l2_v"
        case activeVoltageL3 = "active_voltage_l3_v"
        case activeCurrent = "active_current_a"
        case activeCurrentL1 = "active_current_l1_a"
        case activeCurrentL2 = "active_current_l2_a"
        case activeCurrentL3 = "active_current_l3_a"
        case activeFrequency = "active_frequency_hz"
        case voltageSagL1 = "voltage_sag_l1_count"
        case voltageSagL2 = "voltage_sag_l2_count"
        case voltageSagL3 = "voltage_sag_l3_count"
        case voltageSwellL1 = "voltage_swell_l1_count"
        case voltageSwellL2 = "voltage_swell_l2_count"
        case voltageSwellL3 = "voltage_swell_l3_count"
        case anyPowerFailCount = "any_power_fail_count"
        case longPowerFailCount = "long_power_fail_count"
        case activePowerAverage = "active_power_average_w"
        // Note the typo within the API
        case monthlyPowerPeak = "montly_power_peak_w"
        // Note the typo within the API
        case monthlyPowerPeakDate = "montly_power_peak_timestamp"
        case externalData = "external"
    }
}

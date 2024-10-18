
import XCTest
@testable import HWLocalAPI

final class KwhMeterTests: XCTestCase {
    private let infoData = """
    {
        "product_name": "KWh Meter 3-phase",
        "product_type": "HWE-KWH3",
        "serial": "3c39e0000000",
        "firmware_version": "4.06",
        "api_version": "v1"
    }
    """.data(using: .utf8)!

    private let dataData = """
    {
        "wifi_ssid": "MyWiFi",
        "wifi_strength": 48,
        "total_power_import_kwh": 4418.417,
        "total_power_import_t1_kwh": 4418.417,
        "total_power_export_kwh": 1.234,
        "total_power_export_t1_kwh": 5.678,
        "active_power_w": 3463.347,
        "active_power_l1_w": 3463.347,
        "active_power_l2_w": 1,
        "active_power_l3_w": 1,
        "active_voltage_v": 230.49,
        "active_voltage_l1_v": 230.49,
        "active_voltage_l2_v": 232.883,
        "active_voltage_l3_v": 233.117,
        "active_current_a": 15.01,
        "active_current_l1_a": 15.01,
        "active_current_l2_a": 1.23,
        "active_current_l3_a": 4.56,
        "active_apparent_current_a": 15.014,
        "active_apparent_current_l1_a": 15.014,
        "active_apparent_current_l2_a": 1.23,
        "active_apparent_current_l3_a": 4.56,
        "active_reactive_current_a": 0.378,
        "active_reactive_current_l1_a": 0.378,
        "active_reactive_current_l2_a": 1.23,
        "active_reactive_current_l3_a": 4.56,
        "active_apparent_power_va": 3460.649,
        "active_apparent_power_l1_va": 3460.649,
        "active_apparent_power_l2_va": 1.23,
        "active_apparent_power_l3_va": 4.56,
        "active_reactive_power_var": -87.157,
        "active_reactive_power_l1_var": -87.157,
        "active_reactive_power_l2_var": 1.23,
        "active_reactive_power_l3_var": 4.56,
        "active_power_factor": 1,
        "active_power_factor_l1": 1,
        "active_power_factor_l2": 1,
        "active_power_factor_l3": 1,
        "active_frequency_hz": 49.964
    }
    """.data(using: .utf8)!

    func testDecoding() throws {
        let device = try JSONDecoder().decode(KwhMeter.self, from: infoData)

        XCTAssertEqual(device.name, "KWh Meter 3-phase")
        XCTAssertEqual(device.type, .kwhMeter3Phase)
        XCTAssertEqual(device.serial, "3c39e0000000")
        XCTAssertEqual(device.firmwareVersion, "4.06")
        XCTAssertEqual(device.apiVersion, "v1")
    }

    func testEncoding() throws {
        let device = try JSONDecoder().decode(KwhMeter.self, from: infoData)

        let encoded = try JSONEncoder().encode(device)
        let decoded = try JSONDecoder().decode(KwhMeter.self, from: encoded)
        XCTAssertEqual(device, decoded)
    }

    func testDataDecoding() throws {
        let data = try JSONDecoder().decode(KwhMeterData.self, from: dataData)

        XCTAssertEqual(data.wifiSSID, "MyWiFi")
        XCTAssertEqual(data.wifiStrength, 48)

        XCTAssertEqual(data.totalEnergyImport, 4418.417)
        XCTAssertEqual(data.totalEnergyExport, 1.234)

        XCTAssertEqual(data.activePower, 3463.347)
        XCTAssertEqual(data.activePowerL1, 3463.347)
        XCTAssertEqual(data.activePowerL2, 1)
        XCTAssertEqual(data.activePowerL3, 1)

        XCTAssertEqual(data.activeVoltage, 230.49)
        XCTAssertEqual(data.activeVoltageL1, 230.49)
        XCTAssertEqual(data.activeVoltageL2, 232.883)
        XCTAssertEqual(data.activeVoltageL3, 233.117)

        XCTAssertEqual(data.activeCurrent, 15.01)
        XCTAssertEqual(data.activeCurrentL1, 15.01)
        XCTAssertEqual(data.activeCurrentL2, 1.23)
        XCTAssertEqual(data.activeCurrentL3, 4.56)

        XCTAssertEqual(data.activeApparentCurrent, 15.014)
        XCTAssertEqual(data.activeApparentCurrentL1, 15.014)
        XCTAssertEqual(data.activeApparentCurrentL2, 1.23)
        XCTAssertEqual(data.activeApparentCurrentL3, 4.56)

        XCTAssertEqual(data.activeReactiveCurrent, 0.378)
        XCTAssertEqual(data.activeReactiveCurrentL1, 0.378)
        XCTAssertEqual(data.activeReactiveCurrentL2, 1.23)
        XCTAssertEqual(data.activeReactiveCurrentL3, 4.56)

        XCTAssertEqual(data.activeApparentPower, 3460.649)
        XCTAssertEqual(data.activeApparentPowerL1, 3460.649)
        XCTAssertEqual(data.activeApparentPowerL2, 1.23)
        XCTAssertEqual(data.activeApparentPowerL3, 4.56)

        XCTAssertEqual(data.activeReactivePower, -87.157)
        XCTAssertEqual(data.activeReactivePowerL1, -87.157)
        XCTAssertEqual(data.activeReactivePowerL2, 1.23)
        XCTAssertEqual(data.activeReactivePowerL3, 4.56)

        XCTAssertEqual(data.activePowerFactor, 1)
        XCTAssertEqual(data.activePowerFactorL1, 1)
        XCTAssertEqual(data.activePowerFactorL2, 1)
        XCTAssertEqual(data.activePowerFactorL3, 1)

        XCTAssertEqual(data.activeFrequency, 49.964)
    }
}

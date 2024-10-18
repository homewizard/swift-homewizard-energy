
import XCTest
@testable import HWLocalAPI

final class EnergySocketTests: XCTestCase {
    private let infoData = """
    {
        "product_name": "Energy Socket",
        "product_type": "HWE-SKT",
        "serial": "5c2f00000000",
        "firmware_version": "4.07",
        "api_version": "v1"
    }
    """.data(using: .utf8)!

    private let dataData = """
    {
        "wifi_ssid": "MyWiFi",
        "wifi_strength": 78,
        "total_power_import_kwh": 34.790,
        "total_power_import_t1_kwh": 34.790,
        "total_power_export_kwh": 1.234,
        "total_power_export_t1_kwh": 0.000,
        "active_power_w": 2.359,
        "active_power_l1_w": 2.359,
        "active_voltage_v": 232.695,
        "active_current_a": 0.026,
        "active_reactive_power_var": 1.000,
        "active_apparent_power_va": 2.359,
        "active_power_factor": 1.000,
        "active_frequency_hz": 50.020
    }
    """.data(using: .utf8)!

    private let stateData = """
    {
       "power_on": true,
       "switch_lock": true,
       "brightness": 255
    }
    """.data(using: .utf8)!

    func testDecoding() throws {
        let device = try JSONDecoder().decode(EnergySocket.self, from: infoData)

        XCTAssertEqual(device.name, "Energy Socket")
        XCTAssertEqual(device.type, .energySocket)
        XCTAssertEqual(device.serial, "5c2f00000000")
        XCTAssertEqual(device.firmwareVersion, "4.07")
        XCTAssertEqual(device.apiVersion, "v1")
    }

    func testEncoding() throws {
        let device = try JSONDecoder().decode(EnergySocket.self, from: infoData)

        let encoded = try JSONEncoder().encode(device)
        let decoded = try JSONDecoder().decode(EnergySocket.self, from: encoded)
        XCTAssertEqual(device, decoded)
    }

    func testDataDecoding() throws {
        let data = try JSONDecoder().decode(EnergySocketData.self, from: dataData)

        XCTAssertEqual(data.wifiSSID, "MyWiFi")
        XCTAssertEqual(data.wifiStrength, 78)

        XCTAssertEqual(data.totalPowerImport, 34.790)
        XCTAssertEqual(data.totalPowerExport, 1.234)

        XCTAssertEqual(data.activePower, 2.359)
        XCTAssertEqual(data.activeCurrent, 0.026)
        XCTAssertEqual(data.activeVoltage, 232.695)

        XCTAssertEqual(data.activeReactivePower, 1.000)
        XCTAssertEqual(data.activeApparentPower, 2.359)
        XCTAssertEqual(data.activePowerFactor, 1.000)
        XCTAssertEqual(data.activeFrequency, 50.020)
    }

    func testStateDecoding() throws {
        let state = try JSONDecoder().decode(EnergySocketState.self, from: stateData)

        XCTAssertTrue(state.isPoweredOn)
        XCTAssertTrue(state.isSwitchLocked)
        XCTAssertEqual(state.brightness, 255)
    }
}

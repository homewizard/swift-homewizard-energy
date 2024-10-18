
import XCTest
@testable import HWLocalAPI

final class P1MeterTests: XCTestCase {
    private let infoData = """
    {
        "product_name": "P1 Meter",
        "product_type": "HWE-P1",
        "serial": "3c39e0000000",
        "firmware_version": "5.18",
        "api_version": "v1"
    }
    """.data(using: .utf8)!

    private let dataData = """
    {
        "wifi_ssid": "MyWiFi",
        "wifi_strength": 44,
        "smr_version": 42,
        "meter_model": "Landis + Gyr GBBFG1009147807",
        "unique_id": "4530303330303000000000000000000000",
        "active_tariff": 2,
        "total_power_import_kwh": 581722.707,
        "total_power_import_t1_kwh": 234950.379,
        "total_power_import_t2_kwh": 346772.328,
        "total_power_export_kwh": 8.883,
        "total_power_export_t1_kwh": 5.975,
        "total_power_export_t2_kwh": 2.908,
        "active_power_w": 15424.000,
        "active_power_l1_w": 4297.000,
        "active_power_l2_w": 4150.000,
        "active_power_l3_w": 6977.000,
        "active_current_a": 70.000,
        "active_current_l1_a": 19.000,
        "active_current_l2_a": 19.000,
        "active_current_l3_a": 32.000,
        "active_voltage_l1_v": 232.9,
        "active_voltage_l2_v": 231.9,
        "voltage_sag_l1_count": 1.000,
        "voltage_sag_l2_count": 1.000,
        "voltage_sag_l3_count": 2.000,
        "voltage_swell_l1_count": 1.000,
        "voltage_swell_l2_count": 2.000,
        "voltage_swell_l3_count": 3.000,
        "any_power_fail_count": 4.000,
        "long_power_fail_count": 5.000,
        "external": [
            {
                "unique_id": "4730303137353931323336000000000000",
                "type": "gas_meter",
                "timestamp": 241008120102,
                "value": 68925.426,
                "unit": "m3"
            },
            {
                "unique_id": "4730303137353931323336000000000001",
                "type": "water_meter",
                "timestamp": 221216121314,
                "value": 333.333,
                "unit": "m3"
            }
        ]
    }
    """.data(using: .utf8)!

    func testDecoding() throws {
        let device = try JSONDecoder().decode(P1Meter.self, from: infoData)

        XCTAssertEqual(device.name, "P1 Meter")
        XCTAssertEqual(device.type, .p1Meter)
        XCTAssertEqual(device.serial, "3c39e0000000")
        XCTAssertEqual(device.firmwareVersion, "5.18")
        XCTAssertEqual(device.apiVersion, "v1")
    }

    func testEncoding() throws {
        let device = try JSONDecoder().decode(P1Meter.self, from: infoData)

        let encoded = try JSONEncoder().encode(device)
        let decoded = try JSONDecoder().decode(P1Meter.self, from: encoded)
        XCTAssertEqual(device, decoded)
    }

    func testDataDecoding() throws {
        let data = try JSONDecoder().decode(P1MeterData.self, from: dataData)

        // Wi-Fi info assertions
        XCTAssertEqual(data.wifiSSID, "MyWiFi")
        XCTAssertEqual(data.wifiStrength, 44)

        // Smart Meter info assertions
        XCTAssertEqual(data.smrVersion, 42)
        XCTAssertEqual(data.meterModel, "Landis + Gyr GBBFG1009147807")
        XCTAssertEqual(data.uniqueId, "4530303330303000000000000000000000")

        // Energy Totals assertions
        XCTAssertEqual(data.totalEnergyImport, 581722.707)
        XCTAssertEqual(data.totalEnergyImportT1, 234950.379)
        XCTAssertEqual(data.totalEnergyImportT2, 346772.328)
        XCTAssertEqual(data.totalEnergyExport, 8.883)
        XCTAssertEqual(data.totalEnergyExportT1, 5.975)
        XCTAssertEqual(data.totalEnergyExportT2, 2.908)

        // Active Measurements assertions
        XCTAssertEqual(data.activePower, 15424.000)
        XCTAssertEqual(data.activePowerL1, 4297.000)
        XCTAssertEqual(data.activePowerL2, 4150.000)
        XCTAssertEqual(data.activePowerL3, 6977.000)
        XCTAssertEqual(data.activeCurrent, 70.000)
        XCTAssertEqual(data.activeCurrentL1, 19.000)
        XCTAssertEqual(data.activeCurrentL2, 19.000)
        XCTAssertEqual(data.activeCurrentL3, 32.000)
        XCTAssertEqual(data.activeVoltageL1, 232.9)
        XCTAssertEqual(data.activeVoltageL2, 231.9)
        XCTAssertNil(data.activeVoltageL3)

        // Voltage Sags and Swells assertions
        XCTAssertEqual(data.voltageSagL1, 1)
        XCTAssertEqual(data.voltageSagL2, 1)
        XCTAssertEqual(data.voltageSagL3, 2)
        XCTAssertEqual(data.voltageSwellL1, 1)
        XCTAssertEqual(data.voltageSwellL2, 2)
        XCTAssertEqual(data.voltageSwellL3, 3)

        // Power Failures assertions
        XCTAssertEqual(data.anyPowerFailCount, 4)
        XCTAssertEqual(data.longPowerFailCount, 5)

        // External data assertions
        XCTAssertEqual(data.externalData.count, 2)
        if data.externalData.count == 2 {
            XCTAssertEqual(data.externalData[0].uniqueId, "4730303137353931323336000000000000")
            XCTAssertEqual(data.externalData[0].type, .gasMeter)
            XCTAssertEqual(data.externalData[0].value, 68925.426)
            XCTAssertEqual(data.externalData[0].unit, "m3")
            XCTAssertDate(
                data.externalData[0].timestamp,
                equalsYear: 2024,
                month: 10,
                day: 8,
                hour: 12,
                minute: 1,
                second: 2
            )

            XCTAssertEqual(data.externalData[1].uniqueId, "4730303137353931323336000000000001")
            XCTAssertEqual(data.externalData[1].type, .waterMeter)
            XCTAssertEqual(data.externalData[1].value, 333.333)
            XCTAssertEqual(data.externalData[1].unit, "m3")
            XCTAssertDate(
                data.externalData[1].timestamp,
                equalsYear: 2022,
                month: 12,
                day: 16,
                hour: 12,
                minute: 13,
                second: 14
            )
        }
    }

    func testExternalDeviceTypes() {
        struct TestStruct: Codable {
            var type: P1ExternalDataType
        }

        let data = { (_ raw: String) -> Data in
            """
            {
                "type": "\(raw)"
            }
            """.data(using: .utf8)!
        }

        // Decoding known types
        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("gas_meter"))
            XCTAssertEqual(test.type, .gasMeter)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("heat_meter"))
            XCTAssertEqual(test.type, .heatMeter)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("water_meter"))
            XCTAssertEqual(test.type, .waterMeter)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("warm_water_meter"))
            XCTAssertEqual(test.type, .warmWaterMeter)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("inlet_heat_meter"))
            XCTAssertEqual(test.type, .inletHeatMeter)
        } catch {
            XCTFail("\(error)")
        }

        // Decoding unknown future type
        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("unknown_future_type"))
            XCTAssertEqual(test.type, .unknown(rawValue: "unknown_future_type"))
            XCTAssertEqual(test.type.rawValue, "unknown_future_type")
        } catch {
            XCTFail("\(error)")
        }

        // Encoding
        do {
            let test = TestStruct(type: .gasMeter)
            let coded = try JSONEncoder().encode(test)
            let string = String(data: coded, encoding: .utf8)
            XCTAssertNotNil(string)
            if let string {
                XCTAssertEqual(string, "{\"type\":\"gas_meter\"}")
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}

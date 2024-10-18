
import XCTest
@testable import HWLocalAPI

final class WatermeterTests: XCTestCase {
    private let infoData = """
    {
        "product_name": "Watermeter",
        "product_type": "HWE-WTR",
        "serial": "5c2f00000000",
        "firmware_version": "4.00",
        "api_version": "v1"
    }
    """.data(using: .utf8)!

    private let dataData = """
    {
        "wifi_ssid": "MyWiFi",
        "wifi_strength": 100,
        "total_liter_m3": 335.886,
        "active_liter_lpm": 0.1,
        "total_liter_offset_m3": 0
    }
    """.data(using: .utf8)!

    func testDecoding() throws {
        let device = try JSONDecoder().decode(Watermeter.self, from: infoData)

        XCTAssertEqual(device.name, "Watermeter")
        XCTAssertEqual(device.type, .watermeter)
        XCTAssertEqual(device.serial, "5c2f00000000")
        XCTAssertEqual(device.firmwareVersion, "4.00")
        XCTAssertEqual(device.apiVersion, "v1")
    }

    func testEncoding() throws {
        let device = try JSONDecoder().decode(Watermeter.self, from: infoData)

        let encoded = try JSONEncoder().encode(device)
        let decoded = try JSONDecoder().decode(Watermeter.self, from: encoded)
        XCTAssertEqual(device, decoded)
    }

    func testDataDecoding() throws {
        let data = try JSONDecoder().decode(WatermeterData.self, from: dataData)

        XCTAssertEqual(data.wifiSSID, "MyWiFi")
        XCTAssertEqual(data.wifiStrength, 100)

        XCTAssertEqual(data.totalLiter, 335.886)
        XCTAssertEqual(data.activeLiterPerMinute, 0.1)
    }
}

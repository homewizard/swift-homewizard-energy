//
//  DeviceTests.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 09/10/2024.
//

import XCTest
@testable import HWLocalAPI

final class DeviceTests: XCTestCase {
    func testTypes() {
        struct TestStruct: Codable {
            var type: DeviceType
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
            let test = try JSONDecoder().decode(TestStruct.self, from: data("HWE-P1"))
            XCTAssertEqual(test.type, .p1Meter)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("HWE-SKT"))
            XCTAssertEqual(test.type, .energySocket)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("HWE-WTR"))
            XCTAssertEqual(test.type, .watermeter)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("HWE-KWH1"))
            XCTAssertEqual(test.type, .kwhMeter1Phase)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("HWE-KWH3"))
            XCTAssertEqual(test.type, .kwhMeter3Phase)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("SDM230-wifi"))
            XCTAssertEqual(test.type, .kwhMeter1PhaseEastron)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let test = try JSONDecoder().decode(TestStruct.self, from: data("SDM630-wifi"))
            XCTAssertEqual(test.type, .kwhMeter3PhaseEastron)
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
            let test = TestStruct(type: .p1Meter)
            let coded = try JSONEncoder().encode(test)
            let string = String(data: coded, encoding: .utf8)
            XCTAssertNotNil(string)
            if let string {
                XCTAssertEqual(string, "{\"type\":\"HWE-P1\"}")
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testMapping() throws {
        let json = { (_ raw: String) -> JSON in
            [
                "product_name": "Energy Device",
                "product_type": "\(raw)",
                "serial": "5c2f00000000",
                "firmware_version": "4.44",
                "api_version": "v1"
            ]
        }

        let baseURL = "http://192.168.0.1"

        // Mapping known types
        do {
            let device = try DeviceLoader.load(json: json("HWE-P1"), baseURL: baseURL)
            XCTAssertTrue(device is P1Meter)
            XCTAssertEqual(device.baseURL, baseURL)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let device = try DeviceLoader.load(json: json("HWE-SKT"), baseURL: baseURL)
            XCTAssertTrue(device is EnergySocket)
            XCTAssertEqual(device.baseURL, baseURL)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let device = try DeviceLoader.load(json: json("HWE-WTR"), baseURL: baseURL)
            XCTAssertTrue(device is Watermeter)
            XCTAssertEqual(device.baseURL, baseURL)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let device = try DeviceLoader.load(json: json("HWE-KWH1"), baseURL: baseURL)
            XCTAssertTrue(device is KwhMeter)
            XCTAssertEqual(device.baseURL, baseURL)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let device = try DeviceLoader.load(json: json("HWE-KWH3"), baseURL: baseURL)
            XCTAssertTrue(device is KwhMeter)
            XCTAssertEqual(device.baseURL, baseURL)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let device = try DeviceLoader.load(json: json("SDM230-wifi"), baseURL: baseURL)
            XCTAssertTrue(device is KwhMeter)
            XCTAssertEqual(device.baseURL, baseURL)
        } catch {
            XCTFail("\(error)")
        }

        do {
            let device = try DeviceLoader.load(json: json("SDM630-wifi"), baseURL: baseURL)
            XCTAssertTrue(device is KwhMeter)
            XCTAssertEqual(device.baseURL, baseURL)
        } catch {
            XCTFail("\(error)")
        }

        // Mapping unknown future type
        do {
            let device = try DeviceLoader.load(json: json("unknown_future_type"), baseURL: baseURL)
            XCTAssertTrue(device is UnknownDevice)
            XCTAssertEqual(device.type.rawValue, "unknown_future_type")
            XCTAssertEqual(device.baseURL, baseURL)
        } catch {
            XCTFail("\(error)")
        }
    }
}

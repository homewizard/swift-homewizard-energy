
import XCTest
@testable import HWLocalAPI

/*
 This test will run fine within our time zone,
 but will probably fail when ran in Australia 🫣

 Therefor it's commented out after testing to
 prevent failing test cases in different areas.

 Feel free to add a `/` at the end of the line above
 the class to include it within your tests
 */

/* *
final class APITimeStampTest: XCTestCase {
    func testDefaultMapping() {
        let date = Date(apiTimestamp: 241008111213)
        XCTAssertDate(date, equalsYear: 2024, month: 10, day: 08, hour: 11, minute: 12, second: 13)

        XCTAssertEqual(date?.apiTimestamp(), 241008111213)
    }

    func testZoneMapping() {
        var delta = TimeZone.current.secondsFromGMT()
        let hOffset = delta / 3600
        delta -= hOffset * 3600
        let mOffset = delta / 60
        delta -= mOffset * 60

        let date = Date(apiTimestamp: 241008111213, in: TimeZone(abbreviation: "UTC")!)
        XCTAssertDate(
            date,
            equalsYear: 2024,
            month: 10,
            day: 08,
            hour: 11 + hOffset,
            minute: 12 + mOffset,
            second: 13 + delta
        )
    }
}
// */


import Foundation
import XCTest

extension XCTest {
    func XCTAssertDate(_ expression: @autoclosure () throws -> Date?,
                       equalsYear year: Int,
                       month: Int,
                       day: Int,
                       hour: Int,
                       minute: Int,
                       second: Int,
                       file: StaticString = #filePath,
                       line: UInt = #line) {

        let date: Date
        do {
            guard let validDate = try expression() else {
                XCTFail("Date is nil", file: file, line: line)
                return
            }
            date = validDate

        } catch {
            XCTFail("\(error)", file: file, line: line)
            return
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents(in: .current, from: date)

        XCTAssert(components.year == year, "date's year \(components.year ?? -1) is not equal to expected \(year)", file: file, line: line)
        XCTAssert(components.month == month, "date's month \(components.month ?? -1) is not equal to expected \(month)", file: file, line: line)
        XCTAssert(components.day == day, "date's day \(components.day ?? -1) is not equal to expected \(day)", file: file, line: line)
        XCTAssert(components.hour == hour, "date's hour \(components.hour ?? -1) is not equal to expected \(hour)", file: file, line: line)
        XCTAssert(components.minute == minute, "date's minute \(components.minute ?? -1) is not equal to expected \(minute)", file: file, line: line)
        XCTAssert(components.second == second, "date's second \(components.second ?? -1) is not equal to expected \(second)", file: file, line: line)
    }
}

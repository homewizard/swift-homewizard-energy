//
//  Date+APITimestamp.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 08/10/2024.
//

import Foundation

internal extension Date {
    /**
     Generates a date formatter for the format that is being used by the API

     - parameter zone: TimeZone to use for the formatter
     */
    private static func apiFormatter(in zone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = zone
        formatter.dateFormat = "yyMMddHHmmss"
        return formatter
    }

    /**
     Initializes a new date, using a time stamp as formatted by the API

     > Note:
     Time stamps of these devices are in the local time zone of the smart meter.
     You may optionally specify a time zone in case you want to convert the time stamp
     to a specific zone, rather than using this machine's current zone

     - parameter apiTimestamp: The timestamp received by the API
     - parameter zone: Optional time zone to convert to (default: `.current`)
     */
    init?(apiTimestamp: UInt?, in zone: TimeZone = .current) {
        guard let apiTimestamp else { return nil }

        let formatter = Self.apiFormatter(in: zone)
        guard let date = formatter.date(from: String(apiTimestamp)) else { return nil }
        self = date
    }

    /**
     Converts this date to a time stamp as formatted for the API

     > Note:
     Time stamps of these devices are in the local time zone of the smart meter.
     You may optionally specify a time zone in case you want to convert the time stamp
     to a specific zone, rather than using this machine's current zone

     - parameter zone: Optional time zone to convert to (default: `.current`)
     - returns: The time stamp formatted for the API
     */
    func apiTimestamp(in zone: TimeZone = .current) -> UInt? {
        let formatter = Self.apiFormatter(in: zone)
        let string = formatter.string(from: self)
        return UInt(string)
    }
}

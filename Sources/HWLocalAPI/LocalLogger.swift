//
//  LocalLogger.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 17/10/2024.
//

#if !os(Linux)

import Foundation
import OSLog

internal struct LocalLogger {
    static let bonjour = Logger(subsystem: "nl.homewizard.HWLocalAPI", category: "Bonjour")
    static let local = Logger(subsystem: "nl.homewizard.HWLocalAPI", category: "LocalAPI")
    static let monitor = Logger(subsystem: "nl.homewizard.HWLocalAPI", category: "DeviceMonitor")
}

#endif

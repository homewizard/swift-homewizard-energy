
#if !os(Linux)

import Foundation
import OSLog

internal struct LocalLogger {
    static let bonjour = Logger(subsystem: "nl.homewizard.HWLocalAPI", category: "Bonjour")
    static let local = Logger(subsystem: "nl.homewizard.HWLocalAPI", category: "LocalAPI")
    static let monitor = Logger(subsystem: "nl.homewizard.HWLocalAPI", category: "DeviceMonitor")
}

#endif

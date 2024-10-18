
import Foundation

/**
 # HWLocalError

 Errors being thrown by this package
 */
public enum HWLocalError: Error {
    /// Invalid IP address for a device to fetch
    case invalidAddress
    /// Failed to lookup the IP address of a discovered device
    case ipLookupFailed
    /// The device has local API disabled
    case localAPIDisabled
    /// The base url of the device you're trying to get data from, is unknown
    case unknownBaseURL
    /// The device appears to be offline
    case deviceOffline
}

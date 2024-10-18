//
//  Device.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 04/10/2024.
//

import Foundation

// MARK: - Device

/**
 # Device

 Protocol for the basic information of a HomeWizard device and the source for using its local API.

 ## Device vs DiscoveredDevice

 A `Device` is an actual device object which can be used to communicate with and get data from.
 (Since it's not related to Bonjour, this object is available for Linux as well)

 A ``DiscoveredDevice`` is a device discovered by Bonjour.
 It only has some global info, like the ``DiscoveredDevice/type`` or whether the local API actually ``DiscoveredDevice/isAPIEnabled``.
 It can't be used to 'connect to' or 'fetch data' from.
 (Since a discovered device is related to Bonjour, it will not be available for Linux)

 ## Usage

 To get an instance of a device, you can use the ``DeviceLoader`` with either a ``DiscoveredDevice``,
 discovered by the ``DeviceDiscoveryHandler``, or directly by its IP address.

 Once fetched, you will receive a specific `Device` object based on the type of the device.
 (e.g. a P1 meter will return a ``P1Meter`` object, an EnergySocket will return an ``EnergySocket`` object, etc).

 */
public protocol Device: Codable, Equatable, Sendable, CustomStringConvertible {
    /**
     A fixed, user-friendly name for this device.

     > Note:
     This is **not** the same name (or related to) that is set by the user in the app.
     */
    var name: String { get }
    /// The type of the device
    var type: DeviceType { get }
    /// The serial (also the MAC address) of the device
    var serial: Serial { get }
    /// The current firmware version of the device
    var firmwareVersion: String { get }
    /// The current API version of the device
    var apiVersion: String { get }
    /// The base URL for this device
    var baseURL: String? { get }
}

// MARK: CustomStringConvertible

public extension Device {
    var description: String {
        """
        \(Swift.type(of: self))
            Name: \(name)
            Type: \(type.rawValue)
            Serial: \(serial)
            Firmware version: \(firmwareVersion)
            API version: \(apiVersion)
            Base URL: \(baseURL ?? "nil")
        
        """
    }
}

// MARK: - Internal Device

/// Same as device, just used internally by this package to allow mutating baseURL
internal protocol InternalDevice: Device {
    /// The base URL for this device
    var baseURL: String? { get set }
}

// MARK: - Device Data

/**
 # DeviceData

 Base protocol for device data related structs
 */
public protocol DeviceData: Codable, Sendable {
    /// The Wi-Fi network that the meter is connected to
    var wifiSSID: String { get }
    /// The strength of the Wi-Fi signal in %
    var wifiStrength: Int { get }
}

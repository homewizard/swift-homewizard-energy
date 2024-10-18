//
//  EnergySocket.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 04/10/2024.
//

import Foundation

// MARK: - Energy Socket

/**
 # EnergySocket

 A HomeWizard Energy Socket

 ## Usage

 Besides the regular data (``EnergySocketData``) like all other devices have as well,
 the Energy Socket also has a ``EnergySocketState``, which can be used to
 get/set the power on state of the socket, the LED brightness and whether the socket is switch locked or not.

 ### Socket Data

 To get the latest measurement data of a socket, you can use ``fetchData()``.

 ### Socket State

 To get the current state of the socket, you can use ``fetchState()``.
 If you have changed one or more properties of the state, you can submit them to
 the socket with ``updateState(_:)``

 For convenience, these state properties are also directly available from `EnergySocket` itself.
 They won't be 'saved' though, so they're all `async throws`.

 The convenient properties are:

 - ``isPoweredOn`` and ``setPoweredOn(_:)``
 - ``isSwitchLocked`` and ``setSwitchLocked(_:)``
 - ``brightness`` and ``setBrightness(_:)``

 */
public struct EnergySocket: InternalDevice, IdentifiableDevice {
    public let name: String
    public let type: DeviceType
    public let serial: Serial
    public let firmwareVersion: String
    public let apiVersion: String

    internal(set) public var baseURL: String?

    private enum CodingKeys: String, CodingKey {
        case name = "product_name"
        case type = "product_type"
        case serial
        case firmwareVersion = "firmware_version"
        case apiVersion = "api_version"
    }
}

// MARK: Data fetching

extension EnergySocket {
    /**
     Fetches the most recent measurement from the device

     - returns: The measurement data for this socket
     - throws
     */
    public func fetchData() async throws -> EnergySocketData {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }

        let manager = RequestManager(baseURL: baseURL)
        return try await manager
            .performRequest(
                "/api/\(apiVersion)/data",
                method: .get
            )
    }

    /**
     Fetches the current state of the socket

     - throws
     */
    public func fetchState() async throws -> EnergySocketState {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }

        let manager = RequestManager(baseURL: baseURL)
        return try await manager
            .performRequest(
                "/api/\(apiVersion)/state",
                method: .get
            )
    }

    /**
     Sends the specified state to the socket

     - parameter state: The state to set
     - throws
     */
    public func updateState(_ state: EnergySocketState) async throws {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }

        let manager = RequestManager(baseURL: baseURL)
        try await manager
            .performVoidObjectRequest(
                "/api/\(apiVersion)/state",
                object: state,
                method: .put
            )
    }
}

// MARK: State

extension EnergySocket {

    /**
     The power state of this socket,
     `true` when the relay is in the 'on' state

     - throws
     */
    public var isPoweredOn: Bool {
        get async throws {
            try await fetchState().isPoweredOn
        }
    }

    /**
     Sets the power state for this socket

     - parameter poweredOn: `true` to turn it on, `false` to turn it off
     - throws
     */
    public func setPoweredOn(_ poweredOn: Bool) async throws {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }

        let manager = RequestManager(baseURL: baseURL)
        try await manager
            .performVoidJSONRequest(
                "/api/\(apiVersion)/state",
                json: ["power_on": poweredOn],
                method: .put
            )
    }

    /**
     The switch lock state of this socket.

     When set to `true`, the socket cannot be turned off
     and will automatically turn on after a power outage

     - throws
     */
    public var isSwitchLocked: Bool {
        get async throws {
            try await fetchState().isSwitchLocked
        }
    }

    /**
     Sets the switch lock state for this socket

     - parameter locked: `true` to activate switch lock, `false` to deactivate
     - throws
     */
    public func setSwitchLocked(_ locked: Bool) async throws {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }
        
        let manager = RequestManager(baseURL: baseURL)
        try await manager
            .performVoidJSONRequest(
                "/api/\(apiVersion)/state",
                json: ["switch_lock": locked],
                method: .put
            )
    }

    /**
     Brightness of the LED ring when this socket is 'on'.
     Allowed range: 0...255

     - throws
     */
    public var brightness: Int {
        get async throws {
            try await fetchState().brightness
        }
    }

    /**
     Sets the LED brightness for this socket

     - parameter brightness: The brightness to set (0...255)
     - throws
     */
    public func setBrightness(_ brightness: Int) async throws {
        var brightness = brightness
        if brightness < 0 {
            assertionFailure("Allowed brightness range is 0...255")
            brightness = 0
        } else if brightness > 255 {
            assertionFailure("Allowed brightness range is 0...255")
            brightness = 255
        }

        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }
        
        let manager = RequestManager(baseURL: baseURL)
        try await manager
            .performVoidJSONRequest(
                "/api/\(apiVersion)/state",
                json: ["brightness": brightness],
                method: .put
            )
    }
}

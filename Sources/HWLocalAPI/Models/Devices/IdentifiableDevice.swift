//
//  IdentifiableDevice.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 08/10/2024.
//

import Foundation

/**
 # IdentifiableDevice

 These devices can be used to let the user identify a device.
 (The device's status light will blink for a few seconds after doing so)

 Especially useful in case the user has multiple sockets
 */
public protocol IdentifiableDevice: Device {
    /// Will let the device's status light blink for a few seconds,
    /// allowing the user to identify this specific device
    func identify() async throws
}

extension IdentifiableDevice {
    public func identify() async throws {
        guard let baseURL else {
            throw HWLocalError.unknownBaseURL
        }

        let manager = RequestManager(baseURL: baseURL)
        try await manager
            .performRequest(
                "/api/\(apiVersion)/identify",
                method: .put
            )
    }
}

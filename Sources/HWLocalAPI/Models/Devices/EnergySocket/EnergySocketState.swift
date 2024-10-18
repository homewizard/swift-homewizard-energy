//
//  EnergySocketState.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 08/10/2024.
//

import Foundation

/**
 # EnergySocketState

 State of the ``EnergySocket``
 
 */
public struct EnergySocketState: Codable, Sendable, Equatable {
    /**
     The power state of the socket,
     `true` when the relay is in the 'on' state
     */
    public var isPoweredOn: Bool
    /**
     The switch lock state of the socket.

     When set to `true`, the socket cannot be turned off
     and will automatically turn on after a power outage
     */
    public var isSwitchLocked: Bool
    /**
     Brightness of the LED ring when the socket is 'on'.
     Allowed range: 0...255
     */
    public var brightness: Int {
        didSet {
            if brightness < 0 {
                assertionFailure("Allowed brightness range is 0...255")
                brightness = 0
            } else if brightness > 255 {
                assertionFailure("Allowed brightness range is 0...255")
                brightness = 255
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case isPoweredOn = "power_on"
        case isSwitchLocked = "switch_lock"
        case brightness
    }
}

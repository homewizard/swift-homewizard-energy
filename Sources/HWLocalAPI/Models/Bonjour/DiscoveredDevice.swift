
#if !os(Linux)

import Foundation
import Network

/**
 # DiscoveredDevice

 A HomeWizard device discovered by the ``DeviceDiscoveryHandler`` (using Bonjour).

 > Note:
 Since the discovery will use the Bonjour service, this struct is not available for Linux

 ## DiscoveredDevice vs Device

 A `DiscoveredDevice` is a device discovered by Bonjour.
 It only has some global info, like the ``type`` or whether the local API actually ``isAPIEnabled``.
 It can't be used to 'connect to' or 'fetch data' from (except for identification, see below).

 A ``Device`` is an actual device object which can be used to communicate with and get data from.
 (Since it's not related anymore to Bonjour, this object is available for Linux as well)

 ### From DiscoveredDevice to Device

 There are two ways to get the ``Device`` to work with:

 - use the ``load()`` on a discovered device
 - use the ``DeviceLoader``'s ``DeviceLoader/load(_:)-7uvas``

 ## Identification

 Since a list of devices with only their serial (especially in case a user has multiple sockets)
 might not be that helpful, discovered devices may also be identified by the user.

 When calling ``identify()``, a connection will be setup with the device and it's
 identify feature will be triggered (if supported), which makes it status light blink for a couple of seconds.

 */
public struct DiscoveredDevice: Sendable {
    /**
     A fixed, user-friendly name.

     > Note:
     This name is not the same as that is set by the user in the app.

     */
    public let name: String

    /**
     The type of this device
     */
    public let type: DeviceType

    /// Serial (also the MAC address) of the device
    public let serial: Serial

    /// API path
    public let path: String

    /// Whether the local API of this device is enabled or not
    public let isAPIEnabled: Bool

    /// The bonjour endpoint of this device
    internal let endpoint: NWEndpoint

    /**
     Initializes a new instance

     - parameter result: The browser's result
     */
    internal init?(result: NWBrowser.Result) {
        guard case .bonjour(let record) = result.metadata else { return nil }

        guard let txtRecord = try? JSONDecoder()
            .decode(DiscoveredRecord.self,
                    from: record.dictionary) else { return nil }

        name = txtRecord.name
        type = txtRecord.type
        serial = txtRecord.serial
        path = txtRecord.path
        isAPIEnabled = txtRecord.isAPIEnabled
        self.endpoint = result.endpoint
    }
}

extension DiscoveredDevice: CustomStringConvertible {
    public var description: String {
        "\(name)\t\(serial) (\(isAPIEnabled ? "API Enabled" : "API Disabled"))"
    }
}

extension DiscoveredDevice {
    /// Connects to the endpoint to lookup the base URL for this device
    internal func lookup() async -> String? {
        await withCheckedContinuation { continuation in
            LocalLogger.bonjour.log(level: .debug, "Resolving \(serial, privacy: .public) ")

            let connection = NWConnection(to: endpoint, using: .tcp)
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    var result: String?

                    if let innerEndpoint = connection.currentPath?.remoteEndpoint,
                       case .hostPort(let host, let port) = innerEndpoint {

                        var ip: String?
                        if case .ipv4(let iPv4Address) = host {
                            ip = "\(iPv4Address)".components(separatedBy: "%").first
                        } else if case .ipv6(let iPv6Address) = host {
                            ip = "[\(iPv6Address)]"
                        }

                        if let ip {
                            result = port == 443 ? "https://\(ip)" : "http://\(ip)"
                        }
                    }

                    if let result {
                        LocalLogger.bonjour.log(level: .debug, "\(serial, privacy: .public) resolved to \(result, privacy: .public)")
                    } else {
                        LocalLogger.bonjour.log(level: .error, "Failed to resolve \(serial, privacy: .public)")
                    }

                    connection.cancel()

                    continuation.resume(returning: result)

                default:
                    break
                }
            }
            connection.start(queue: .global(qos: .userInitiated))
        }
    }

    /**
     Initializes a Device and loads additional information for this device.

     Will connect to this device to get its basic information as defined within the ``Device`` protocol.
     It will return a specific object based on the type of the device
     (e.g. a P1 meter will return a ``P1Meter`` object, an Energy Socket will return an ``EnergySocket`` object, etc).

     - returns: The `Device`
     - throws
     */
    public func load() async throws -> any Device {
        try await DeviceLoader.load(self)
    }

    /**
     Tries to connect to the device to identify it.
     When succeeded, the device's status light will blink for a few seconds.

     - throws
     */
    public func identify() async throws {
        // Only works then the API is enabled
        guard isAPIEnabled else {
            throw HWLocalError.localAPIDisabled
        }

        // Lookup the base URL
        guard let baseURL = await lookup()else {
            throw HWLocalError.ipLookupFailed
        }

        LocalLogger.bonjour.log("Identifying \(serial, privacy: .public)")
        let manager = RequestManager(baseURL: baseURL)
        // Just fire and forget this one..
        // all current known types are supporting `identify`,
        // so in case it's type `unknown`, let's hope that one supports
        // it too, otherwise just a nice try
        try? await manager
            .performVoidJSONRequest(
                "/api/v1/identify",
                json: nil,
                method: .put
            )
    }
}

#endif

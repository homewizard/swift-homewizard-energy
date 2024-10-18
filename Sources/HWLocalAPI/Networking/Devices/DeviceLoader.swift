//
//  DeviceLoader.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 08/10/2024.
//

import Foundation

/**
 # DeviceLoader

 Allows you to instantiate a ``Device`` object and loads the global information

 To do so you need to either:

 - have a ``DiscoveredDevice``, discovered by Bonjour
 - already know its IP address (Only option for Linux)

 */
public final class DeviceLoader: Sendable {
    private init() {}

    // MARK: Public accessors

    #if !os(Linux)
    /**
     Instantiate and load a device for the specified entity discovered by bonjour

     - parameter discovered: The discovered entity
     - returns: The loaded device
     - throws
     */
    public static func load(_ discovered: DiscoveredDevice) async throws -> any Device {
        LocalLogger.local.log(level: .debug, "Trying to load device \(discovered.serial, privacy: .public) from discovered device")
        // Verify the API is enabled
        guard discovered.isAPIEnabled else {
            LocalLogger.local.log("Unable to load \(discovered.serial, privacy: .public): Local API is disabled")
            throw HWLocalError.localAPIDisabled
        }

        // Lookup the address of the device
        guard let base = await discovered.lookup() else {
            LocalLogger.local.log("Unable to load \(discovered.serial, privacy: .public): Lookup failed")
            throw HWLocalError.ipLookupFailed
        }

        // Next step: load the JSON
        return try await load(baseURL: base)
    }
    #endif

    /**
     Instantiate and load a device, using an IP address you already know.

     Example:

     ```swift
     let device = try await DeviceLoader.load("192.168.0.10")
     ```

     - parameter address: The IP address
     - returns: The loaded device
     - throws
     */
    public static func load(_ address: IPAddress) async throws -> any Device {
        #if !os(Linux)
        LocalLogger.local.log(level: .debug, "Trying to load device from IP \(address, privacy: .public)")
        #endif

        // form the address
        let urlString: String
        if address.contains("::") {
            urlString = "http://[\(address)]"
        } else {
            urlString = "http://\(address)"
        }

        // validate the address
        guard let url = URL(string: urlString) else {
            #if !os(Linux)
            LocalLogger.local.log("Unable to load \(address, privacy: .public): Invalid URL")
            #endif
            throw HWLocalError.invalidAddress
        }

        // Next step: load the JSON
        return try await load(baseURL: url.absoluteString)
    }

    // MARK: Internal helpers

    /**
     Loads the device using the specified base url.

     The base url would be typically the result of a discovered device lookup,
     or based on the specified IP address

     - parameter baseURL: The base url to use for loading the device
     - returns: The loaded device
     - throws
     */
    internal static func load(baseURL: String) async throws -> any Device {
        let manager = RequestManager(baseURL: baseURL)

        let json: [String: Any]
        do {
            json = try await manager
                .performJSONRequest(
                    "/api",
                    json: nil,
                    method: .get
                )
        } catch {
            if let err = error as? RequestError {
                switch err.kind {
                case .accessForbiddenError:
                    // Device will throw an access forbidden error
                    // in case the local api is disabled...
                    #if !os(Linux)
                    LocalLogger.local.log("Failed to load \(baseURL, privacy: .public): Local API disabled")
                    #endif
                    throw HWLocalError.localAPIDisabled

                case .unableToConnectToServer:
                    #if !os(Linux)
                    LocalLogger.local.log("Failed to load \(baseURL, privacy: .public): Device is offline")
                    #endif
                    throw HWLocalError.deviceOffline

                default:
                    #if !os(Linux)
                    LocalLogger.local.log("Failed to load \(baseURL, privacy: .public): \(error, privacy: .public)")
                    #endif
                    throw error
                }

            } else {
                #if !os(Linux)
                LocalLogger.local.log("Failed to load \(baseURL, privacy: .public): \(error, privacy: .public)")
                #endif
                throw error
            }
        }

        // Next step: Decode the JSON
        return try load(json: json, baseURL: baseURL)
    }

    /**
     Loads the device by decoding the specified JSON.

     The JSON would typically be the result of the loader above,
     but can also be manually created within, for example, test cases
     */
    internal static func load(json: JSON, baseURL: String) throws -> any Device {
        guard let rawType = json["product_type"] as? String,
              let type = DeviceType(rawValue: rawType) else {
            throw RequestError(.unexpectedResponse, message: "Invalid product type")
        }
        #if !os(Linux)
        LocalLogger.local.log(level: .debug, "Loaded device resolved into \(type.rawValue, privacy: .public)")
        #endif

        do {
            var device = try JSONDecoder().decode(type.typeName, from: json)
            device.baseURL = baseURL
            return device
        } catch {
            #if !os(Linux)
            LocalLogger.local.log("Failed to decode device: \(error, privacy: .public)")
            #endif
            throw error
        }
    }
}

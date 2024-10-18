
#if !os(Linux)

import Foundation
import Network

/**
 # DeviceDiscoveryDelegate

 Delegate protocol for the ``DeviceDiscoveryHandler``.

 When continuously monitoring, this delegate will be called when devices are discovered, lost or updated.
 */
public protocol DeviceDiscoveryDelegate: AnyObject {
    /**
     The DeviceDiscoveryHandler discovered a new device

     - parameter handler: The handler that discovered the device
     - parameter device: The device that has been discovered
     */
    func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didDiscover device: DiscoveredDevice)

    /**
     The DeviceDiscoveryHandler lost a device

     - parameter handler: The handler that has lost the device
     - parameter device: The device that has been lost
     */
    func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didLoose device: DiscoveredDevice)

    /**
     The DeviceDiscoveryHandler updated an existing device

     - parameter handler: The handler that updated the device
     - parameter device: The device that has been updated
     - parameter oldDevice: The old version of the device
     */
    func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didUpdate device: DiscoveredDevice, from oldDevice: DiscoveredDevice)
}

/**
 # DeviceDiscoveryHandler

 This handler will discover HomeWizard devices using the Bonjour browser (and thus not available on Linux).

 There are two ways you can use this handler:

 - Continuously monitor the local network for device updates
 - Do a quick lookup for a number of seconds and stop

 ## Usage

 ### Continuously monitor the network

 Create a new instance of the `DeviceDiscoveryHandler` and assign  a ``DeviceDiscoveryDelegate`` to it.

 Use ``start()`` to start monitoring the network and the delegate will be called on each change (discovery, lost, update).
 You may use ``stop()`` to stop the monitor.

 > Note:
 In case you don't want to handle this yourself, you may use the ``DiscoveredDataSource`` as an alternative.

 Example:

 ```swift
 final class Monitor: DeviceDiscoveryDelegate {
     private(set) var discoveredDevices: [DiscoveredDevice] = []
     private var handler: DeviceDiscoveryHandler!

     init() {
         handler = DeviceDiscoveryHandler(delegate: self)
         handler.start()
     }

     deinit {
         handler.stop()
     }

     func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didDiscover device: DiscoveredDevice) {
         discoveredDevices.append(device)
     }

     func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didLoose device: DiscoveredDevice) {
         discoveredDevices
             .removeAll(where: {
                 $0.serial == device.serial
             })
     }

     func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didUpdate device: DiscoveredDevice, from oldDevice: DiscoveredDevice) {
         discoveredDevices
             .removeAll(where: {
                 $0.serial == oldDevice.serial
             })
         discoveredDevices.append(device)
     }
 }
 ```

 ### Quick lookup

 You can use the static ``quickLookup(seconds:)`` to scan the network for a given number of seconds (3 by default) and it will return the list of discovered devices.

 Example:

 ```swift
 final class Preferences {
     func usedDevice() async throws -> (any Device)? {
         guard let serial = UserDefaults
             .standard
             .string(forKey: "usedDevice") else {
             return nil
         }

         let discovered = await DeviceDiscoveryHandler.quickLookup()
         if let device = discovered.first(where: { $0.serial == serial }) {
             return try await device.load()
         } else {
             return nil
         }
     }

     func setUsedDevice(_ device: (any Device)?) {
         UserDefaults.standard.set(device?.serial, forKey: "usedDevice")
     }
 }
 ```

 */
public final class DeviceDiscoveryHandler: @unchecked Sendable {
    /// Running queue
    private let queue = DispatchQueue(label: "nl.homewizard.HWLocalAPI.DiscoveryQueue-\(UUID().uuidString)")

    private var _isRunning: Bool = false
    /// Whether the handler is currently monitoring the network or not
    public var isRunning: Bool {
        queue.sync {
            _isRunning
        }
    }

    /// The browser being used
    private var browser: NWBrowser?
    /// The assigned delegate
    private weak var delegate: DeviceDiscoveryDelegate?

    /**
     Initializes a new Device Discovery Handler using the specified delegate

     - parameter delegate: The delegate for this instance
     */
    public init(delegate: DeviceDiscoveryDelegate) {
        self.delegate = delegate
    }

    // Only our own quick lookup can initialize without delegate
    private init() {}

    /// Start monitoring
    public func start() {
        queue.sync {
            guard !_isRunning else { return }
            _isRunning = true
        }

        LocalLogger.bonjour.log("Starting Bonjour discovery handler")

        let browser = NWBrowser(for: .bonjourWithTXTRecord(type: "_hwenergy._tcp", domain: "local."), using: .tcp)
        browser.browseResultsChangedHandler = {[weak self] updated, changes in
            guard let self else { return }

            for change in changes {
                switch change {
                // A new device was discovered
                case .added(let result):
                    if let device = DiscoveredDevice(result: result) {
                        LocalLogger.bonjour.log(level: .debug, "[ADD] \(device, privacy: .public)")
                        self.delegate?
                            .deviceDiscoveryHandler(
                                self,
                                didDiscover: device
                            )
                    }

                // An already discovered device has been lost
                case .removed(let result):
                    if let device = DiscoveredDevice(result: result) {
                        LocalLogger.bonjour.log(level: .debug, "[REM] \(device, privacy: .public)")
                        self.delegate?
                            .deviceDiscoveryHandler(
                                self,
                                didLoose: device
                            )
                    }

                // An already discovered device has been changed
                case .changed(let old, let new, _):
                    if let oldDevice = DiscoveredDevice(result: old),
                        let newDevice = DiscoveredDevice(result: new) {
                        LocalLogger.bonjour.log(level: .debug, "[UPD] \(oldDevice, privacy: .public) -> \(newDevice, privacy: .public)")
                        self.delegate?
                            .deviceDiscoveryHandler(
                                self,
                                didUpdate: newDevice,
                                from: oldDevice
                            )
                    }

                case .identical:
                    fallthrough
                @unknown default:
                    break
                }
            }
        }

        browser.start(queue: .global())
        self.browser = browser
    }

    /// Stop monitoring
    public func stop() {
        queue.sync {
            guard _isRunning else { return }
        }

        LocalLogger.bonjour.log("Stopping Bonjour discovery handler")

        browser?.cancel()
        browser = nil

        queue.sync {
            _isRunning = false
        }
    }
}

extension DeviceDiscoveryHandler {
    /**
     Will do a quick lookup for a given number of seconds and returns the list of discovered devices

     - parameter seconds: The number of seconds for the lookup (default: `3`)
     - returns: The list of discovered devices
     */
    public static func quickLookup(seconds: Int = 3) async -> [DiscoveredDevice] {
        let handler = DeviceDiscoveryHandler()
        handler.start()

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let appliances = handler.browser?.browseResults.compactMap({ DiscoveredDevice(result: $0) }) ?? []
        handler.stop()

        return appliances
    }
}

#endif

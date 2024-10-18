
#if !os(Linux)

import Foundation

// MARK: - Discovered Data Source

/**
 # DiscoveredDataSource

 A data source that (once started) continuously monitors the network for HomeWizard devices, through Bonjour.

 > Note:
 An alternative way to handle this yourself, can be achieved by using ``DeviceDiscoveryHandler``

 ## Usage

 ### Start the data source

 The data source needs to be started once, by calling the ``start()`` function.
 It will continuously monitor your local network for HomeWizard devices.

 Every time the list of devices did change, the ``didChange`` notification will be posted (without `object` or `userInfo`).

 ### Get discovered devices

 The ``count`` property will tell you how many devices are currently available, which can be listed using ``devices``.

 Alternatively, instead of getting all discovered devices, you may use

 - ``device(withSerial:)`` in case you already know the serial of the device you're interested in
 - ``devices(ofType:)`` in case you want a list of devices of a specific type (e.g. EnergySockets)
 - ``enabledDevices`` in case you want a list of devices that actually have the Local API enabled

 ### Example

 ```swift
 final class Monitor: Sendable {
     private let serials: [String]

     // Serials of devices we're interested in
     init(serials: [String]) {
         self.serials = serials

         NotificationCenter
             .default
             .addObserver(
                 self,
                 selector: #selector(dataSourceDidUpdate(_:)),
                 name: DiscoveredDataSource.didChange,
                 object: nil
             )

         Task {
             if await DiscoveredDataSource.shared.isRunning == false {
                 await DiscoveredDataSource.shared.start()
             }
         }
     }

     deinit {
         NotificationCenter
             .default
             .removeObserver(self)
     }

     @objc private func dataSourceDidUpdate(_ notification: Notification) {
         Task {
             for serial in self.serials {
                 if let discovered = await DiscoveredDataSource
                     .shared
                     .device(withSerial: serial) {
                     // Do something
                 }
             }
         }
     }
 }
 ```

 */
public actor DiscoveredDataSource {
    /// Will  be posted every time the data source changes
    public static let didChange = Notification.Name("DiscoveredDataSourceDidChangeNotification")

    /// Shared singleton
    public static let shared = DiscoveredDataSource()

    /// Whether discovery is running or not
    private(set) public var isRunning: Bool = false

    /// Actual data store
    private var store: [DiscoveredDevice] = []
    /// Discovery handler
    private var handler: DeviceDiscoveryHandler?
    /// Timer to prevent spamming the notifications
    private var notifyTimer: Timer?

    private init() {}

    /**
     Starts discovery

     The current data store will be cleared first
     */
    public func start() {
        guard !isRunning else { return }
        isRunning = true
        store = []

        let handler = DeviceDiscoveryHandler(delegate: self)
        handler.start()
        self.handler = handler
    }

    /**
     Stops discovery

     The data store will remain available
     */
    public func stop() {
        guard isRunning else { return }
        handler?.stop()
        handler = nil

        isRunning = false
    }
}

// MARK: - Data Source

extension DiscoveredDataSource {
    /// Number of discovered devices
    public var count: Int {
        store.count
    }

    /**
     All discovered devices

     > Note:
     This will also return devices that don't have their local API enabled.
     Use ``enabledDevices`` to get a list of only the enabled devices.
     */
    public var devices: [DiscoveredDevice] {
        store
    }

    /**
     Returns the device with the specified serial, or `nil` when not found

     - parameter serial: The serial of the device to get
     - returns: The device with the specified serial, or `nil`
     */
    public func device(withSerial serial: Serial) -> DiscoveredDevice? {
        store.first(where: { $0.serial == serial })
    }

    /**
     Returns all devices of the specified type

     - parameter type: The type of the devices to get
     - returns: A list with the requested devices
     */
    public func devices(ofType type: DeviceType) -> [DiscoveredDevice] {
        store.filter({ $0.type == type })
    }

    /// All devices that have their local API enabled
    public var enabledDevices: [DiscoveredDevice] {
        store.filter({ $0.isAPIEnabled })
    }
}

// MARK: - Discovery Delegate

extension DiscoveredDataSource: DeviceDiscoveryDelegate {
    /**
     This will handle posting the did change notification.

     Rather than spamming the notification when multiple devices have been discovered
     (especially when just started), we'll just wait for a bit and post it once
     */
    private func notify() {
        notifyTimer?.invalidate()

        let timer = Timer(timeInterval: 0.75, repeats: false, block: { timer in
            guard timer.isValid else { return }
            NotificationCenter.default.post(name: Self.didChange, object: nil)
        })
        RunLoop.main.add(timer, forMode: .common)
        self.notifyTimer = timer
    }

    private func update(_ device: DiscoveredDevice) {
        store.removeAll(where: { $0.serial == device.serial })
        store.append(device)
        notify()
    }

    private func remove(_ device: DiscoveredDevice) {
        store.removeAll(where: { $0.serial == device.serial })
        notify()
    }

    nonisolated public func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didDiscover device: DiscoveredDevice) {
        Task {
            await self.update(device)
        }
    }
    
    nonisolated public func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didLoose device: DiscoveredDevice) {
        Task {
            await self.remove(device)
        }
    }
    
    nonisolated public func deviceDiscoveryHandler(_ handler: DeviceDiscoveryHandler, didUpdate device: DiscoveredDevice, from oldDevice: DiscoveredDevice) {
        Task {
            await self.update(device)
        }
    }
}

#endif

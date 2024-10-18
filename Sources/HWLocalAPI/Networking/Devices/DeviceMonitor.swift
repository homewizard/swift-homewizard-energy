//
//  DeviceMonitor.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 10/10/2024.
//

import Foundation

/**
 # DeviceMonitor

 The device monitor can be used to repetitively fetch an update of the data of one or more devices.
 The time interval between each update is defined by ``updateInterval``.

 ## Usage

 You can either use the ``default`` instance of this monitor (with an update interval of each 5 seconds), or create your own
 instance.

 Once the monitor has been started using ``start()``, it will fetch an update of the data of each device being monitored,
 with a time interval as specified by ``updateInterval`` (which can only be set during initialization).

 For each update either a ``didUpdate`` or ``didFail`` notification will be send through the default Notification Center.

 ### Manage devices

 Use ``add(_:)-327xc`` to add a device to this monitor, or ``add(_:)-5uvev`` to add a list of devices.

 To remove devices from this monitor you can use either ``remove(_:)-3gtil`` or ``remove(_:)-745xv``
 to remove a single device, and ``remove(_:)-35a3b`` to remove multiple devices.

 When devices are added when the monitor was already started, the first data fetch will take place the first
 time the update interval is being triggered (thus not instantly when the device has been added).

 ### Notifications

 Once a new data update has been fetched for a specific device, the ``didUpdate`` notification will be posted
 through the default Notification Center.

 The `object` of the notification will be the serial of the device it's been related to.
 The notification's `userInfo` will have a key ``UserInfo/date`` with the time stamp of the update,
 together with a key ``UserInfo/data`` containing the received data.

 The type of the data will be depending on the related device.
 A ``P1Meter``, for example, will always result into data of type ``P1MeterData``,
 a ``EnergySocket`` will always result into data of type ``EnergySocketData``, etc.

 In case an update fails for a specific device, the ``didFail`` notification will be posted
 through the default Notification Center.

 The `object` of the notification will be the serial of the device it's been related to.
 The notification's `userInfo` will have a key ``UserInfo/date`` with the time stamp of the failure,
 together with a key ``UserInfo/error`` containing the `Error` that occurred.

 ### Start and Stop

 To actually start fetching data repetitively, the function ``start()`` should have been called once,
 which can be checked by ``isRunning``.

 To stop or pause fetching data, you can use ``stop()``.
 To continue, you may just call `start()` again (thus no need to re-initialize a new instance).

 ## Example

 ```swift
 final class Monitor: Sendable {
     /// Devices to monitor
     private let devices: [any Device]

     init(devices: [any Device]) {
         self.devices = devices

         // Register the observers
         NotificationCenter
             .default
             .addObserver(
                 self,
                 selector: #selector(dataReceived(_:)),
                 name: DeviceMonitor.didUpdate,
                 object: nil
             )

         NotificationCenter
             .default
             .addObserver(
                 self,
                 selector: #selector(dataFailed(_:)),
                 name: DeviceMonitor.didFail,
                 object: nil
             )

         // Add the devices to monitor
         DeviceMonitor.default.add(devices)
         // Start the monitor if needed
         if !DeviceMonitor.default.isRunning {
             DeviceMonitor.default.start()
         }
     }

     deinit {
         DeviceMonitor.default.remove(self.devices)
         NotificationCenter.default.removeObserver(self)
     }

     @objc private func dataReceived(_ notification: Notification) {
         if let serial = notification.object as? Serial,
            let data = notification.userInfo?[DeviceMonitor.UserInfo.data] as? (any DeviceData) {

             // Do something with the data
             print("Received data update for \(serial):\n\(data)")
         }
     }

     @objc private func dataFailed(_ notification: Notification) {
         if let serial = notification.object as? Serial,
            let error = notification.userInfo?[DeviceMonitor.UserInfo.error] as? Error {

             // Do something with the error
             print("Receiving data failed for \(serial):\n\(error)")
         }
     }
 }
 ```
 */
public final class DeviceMonitor: @unchecked Sendable {
    /**
     # UserInfo

     Keys used for the `userInfo` within the `Notification`s for ``didUpdate`` and ``didFail``.

     Both notifications will have ``UserInfo/date``, depending whether the update succeeded or failed, the user info will also have ``UserInfo/data`` or ``UserInfo/error``.

     */
    public struct UserInfo {
        private init() {}

        /// Received data
        public static let data = "Data"
        /// Time stamp of the data retrieval
        public static let date = "Date"
        /// Error that occurred
        public static let error = "Error"
    }

    /**
     Will be posted when the data of a device has been updated.

     The `object` of the Notification will be the serial of the related ``Device``.
     See ``DeviceMonitor/UserInfo`` for the contents of the notification's `userInfo`.

     This notification will always be posted on the main thread.
     */
    public static let didUpdate = Notification.Name("DeviceDataDidUpdateNotification")
    /**
     Will be posted when the data update of a device has been failed.

     The `object` of the Notification will be the serial of the related ``Device``.
     See ``DeviceMonitor/UserInfo`` for the contents of the notification's `userInfo`.

     This notification will always be posted on the main thread.
     */
    public static let didFail = Notification.Name("DeviceDataDidFailNotification")

    /**
     Default, shared instance of the device monitor with an update interval of 5 seconds.
     */
    public static let `default` = DeviceMonitor(updateInterval: 5)

    private let queue = DispatchQueue(label: "nl.homewizard.HWLocalAPI.DeviceMonitor-\(UUID().uuidString)")

    /**
     Time interval for the data updates for this monitor.
     */
    public let updateInterval: TimeInterval

    /**
     List of devices to get data updates for.

     Use ``add(_:)-327xc`` to add a device to this monitor, or ``add(_:)-5uvev`` to add a list of devices.

     To remove devices from this monitor you can use either ``remove(_:)-3gtil`` or ``remove(_:)-745xv``
     to remove a single device, and ``remove(_:)-35a3b`` to remove multiple devices.

     > Note:
     When new devices are added, the first data update will be the first time this monitor's ``updateInterval`` triggers (thus not instantly upon adding).

     */
    private(set) public var devices: [any Device]

    private var _isRunning: Bool = false
    /// Whether the monitor is currently running or not
    public var isRunning: Bool {
        queue.sync {
            _isRunning
        }
    }

    /// Update timer
    private var timer: Timer?
    /// Request manager to use
    private let manager = RequestManager(baseURL: "")

    /**
     Initializes a new device monitor.

     The new instance will use the specified timer interval to update the data.

     > Note:
     The time interval should at least be 1 second.

     - parameter updateInterval: The time interval between updates
     */
    public init(updateInterval: TimeInterval) {
        assert(updateInterval >= 1)
        self.devices = []
        self.updateInterval = updateInterval
    }

    /**
     Adds a device to this monitor

     - parameter device: The device to add
     */
    public func add(_ device: any Device) {
        self.add([device])
    }

    /**
     Adds one or more devices to this monitor

     - parameter devices: The devices to add
     */
    public func add(_ devices: [any Device]) {
        let serialMap = devices.map(\.serial)
        queue.sync {
            self.devices.removeAll(where: { serialMap.contains($0.serial) })
            self.devices.append(contentsOf: devices)
        }
    }

    /**
     Removes a device from this monitor.

     - parameter device: The device to remove
     */
    public func remove(_ device: any Device) {
        self.remove([device])
    }

    /**
     Removes one or more devices from this monitor.

     - parameter devices: The devices to remove
     */
    public func remove(_ devices: [any Device]) {
        let serialMap = devices.map(\.serial)
        queue.sync {
            self.devices.removeAll(where: { serialMap.contains($0.serial) })
        }
    }

    /**
     Removes a device from this monitor.

     - parameter serial: The serial of the device to remove
     */
    public func remove(_ serial: Serial) {
        queue.sync {
            devices.removeAll(where: { $0.serial == serial })
        }
    }

    /// Starts the monitor
    public func start() {
        queue.sync {
            guard !_isRunning else { return }
            _isRunning = true
        }

        #if !os(Linux)
        LocalLogger.monitor.log("Starting device monitor (\(self.devices.count) devices)")
        #endif
        let timer = Timer(timeInterval: updateInterval,
                          repeats: true) { [weak self] timer in

            guard let self, timer.isValid else { return }
            self.update()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer

        // Also do an instant update now
        self.update()
    }

    /// Stops the monitor
    public func stop() {
        queue.sync {
            guard _isRunning else { return }
        }

        #if !os(Linux)
        LocalLogger.monitor.log("Stopping device monitor")
        #endif

        timer?.invalidate()
        timer = nil

        queue.sync {
            _isRunning = false
        }
    }
}

extension DeviceMonitor {
    /**
     Update trigger, invoked by the timer

     - parameter timer: The timer that called us
     */
    private func update() {
        #if !os(Linux)
        LocalLogger.monitor.log(level: .debug, "Monitor update triggered")
        #endif

        var devices = [any Device]()
        queue.sync { devices = self.devices }

        for device in devices {
            Task {
                await fetchData(for: device)
            }
        }
    }

    /**
     Actually fetching the data of a specific device

     - parameter device: The device to fetch the data from
     */
    private func fetchData(for device: any Device) async {
        guard let dataType = device.type.dataName else { return }
        #if !os(Linux)
        LocalLogger.monitor.log(level: .debug, "Fetching data for \(device.serial, privacy: .public)")
        #endif

        // Time stamp of this fetch
        let date = Date()
        do {
            guard let baseURL = device.baseURL else {
                throw HWLocalError.unknownBaseURL
            }

            let rawData: Data = try await manager
                .performRequest(
                    "\(baseURL)/api/\(device.apiVersion)/data",
                    method: .get
                )
            let data = try JSONDecoder().decode(dataType, from: rawData)

            // When reached this point, the update succeeded..
            // Post an update notification
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Self.didUpdate,
                    object: device.serial,
                    userInfo: [
                        UserInfo.date: date,
                        UserInfo.data: data
                    ]
                )
            }

        } catch {
            #if !os(Linux)
            LocalLogger.monitor.log(level: .error, "Fetching data for \(device.serial, privacy: .public) failed: \(error, privacy: .public)")
            #endif
            // When reaching this point, the update failed..
            // Post a failed notification
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Self.didFail,
                    object: device.serial,
                    userInfo: [
                        UserInfo.date: date,
                        UserInfo.error: error
                    ]
                )
            }
        }
    }
}

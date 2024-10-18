# Monitoring

@Metadata {
    @PageImage(purpose: icon, source: "hw_logo_large")
}

Continuously monitor data of one or more devices

## Overview

This article will describe how you can continuously monitor the data of one or more devices,
by using a ``DeviceMonitor``.

A single instance of a device monitor (either a custom instance or the predefined 
``DeviceMonitor/default`` one) can 'monitor' multiple devices by fetching their latest
measurement data repetitively by the assigned ``DeviceMonitor/updateInterval`` in seconds.

## Usage

You can either use the ``DeviceMonitor/default`` instance which will get a data update each 5 seconds,
or create your own instance with your preferred update interval (>= 1 second).

Once the monitor has been started using its ``DeviceMonitor/start()`` function, it will fetch 
an update of the data of each device being monitored with the interval that has been set.

For each update, either a ``DeviceMonitor/didUpdate`` or ``DeviceMonitor/didFail`` notification 
will be send through the default Notification Center.

> Note:
Each monitored device will be updated separately, thus post its own notification.
In case updating one device fails, this will not interfere with the updates of the 
other devices.

### Notifications

Once a new data update has been fetched for a specific device, the ``DeviceMonitor/didUpdate``
notification will be posted through the default Notification Center.

The `object` of the notification will be the serial of the device it's been related to.
The notification's `userInfo` will have a key ``DeviceMonitor/UserInfo/date`` with the time stamp of
the update, together with a key ``DeviceMonitor/UserInfo/data`` containing the received data.

The type of the data will be depending on the related device.
A ``P1Meter``, for example, will always result into data of type ``P1MeterData``,
an ``EnergySocket`` will always result into data of type ``EnergySocketData``, etc.

In case an update fails for a specific device, the ``DeviceMonitor/didFail`` notification 
will be posted through the default Notification Center.

The `object` of the notification will be the serial of the device it's been related to.
The notification's `userInfo` will have a key ``DeviceMonitor/UserInfo/date`` with the time stamp 
of the failure, together with a key ``DeviceMonitor/UserInfo/error`` containing the `Error` 
that occurred.

### Example

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

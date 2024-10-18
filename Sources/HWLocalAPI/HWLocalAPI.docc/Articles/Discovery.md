# Discovery

@Metadata {
    @PageImage(purpose: icon, source: "hw_logo_large")
}

Bonjour services allows us to discover HomeWizard Energy devices on the local network.

## Overview

Using Bonjour, we can discover HomeWizard Energy <doc:Devices> on the local network, including some additional information like
the type of the device and whether de local API is actually enabled or not.

`HWLocalAPI` provides you with some basic tools to get a list of these devices and/or monitor real-time changes
(e.g. new devices coming online or existing devices going offline).

> Note:
All bonjour related code is **not** available for Linux.

## Usage

There are three ways to use the bonjour discovery:

- Use the actor based data source that will monitor the network for you
- Use the handler and get a quick lookup of the device currently on your network
- Use the handler and delegate the continuously discovery yourself

### Actor based data source

You may use ``DiscoveredDataSource`` as a data source for HomeWizard Energy devices that
are available on your local network.

The data source needs to be started once, using ``DiscoveredDataSource/start()`` on the ``DiscoveredDataSource/shared`` singleton, and then it will continuously monitor your local 
network for HomeWizard Energy devices.

Every time its list of devices is being changed, the ``DiscoveredDataSource/didChange`` notification
will be posted through the default Notification Center.

The ``DiscoveredDataSource/count`` property will tell you how many devices are currently available, which can be listed using ``DiscoveredDataSource/devices``.

Alternatively, instead of getting all discovered devices, you may use

- ``DiscoveredDataSource/device(withSerial:)`` in case you already know the serial of the device you're interested in
- ``DiscoveredDataSource/devices(ofType:)`` in case you want a list of devices of a specific type (e.g. EnergySockets)
- ``DiscoveredDataSource/enabledDevices`` in case you want a list of devices that actually have the Local API enabled

#### Example code

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

### Discovery handler

Alternatively you may use ``DeviceDiscoveryHandler`` to monitor your local network.

There are two ways you can use this handler:

- Continuously monitor the local network for device updates and provide a delegate to respond to them
- Do a quick lookup for a number of seconds and get a list of devices that have been discovered.

#### Continuously monitoring

To continuously monitor your network, create a new instance of ``DeviceDiscoveryHandler`` and
assign a ``DeviceDiscoveryDelegate`` to it.

Use ``DeviceDiscoveryHandler/start()`` to start monitoring the network and the delegate will be called on each change (discovery, lost, update).
You may use ``DeviceDiscoveryHandler/stop()`` to stop the monitor.

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

#### Quick lookup

You can use the static ``DeviceDiscoveryHandler/quickLookup(seconds:)`` to scan the network for a given number of seconds (3 by default) and it will return the list of discovered devices.

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

### Identification

Since a list of discovered devices distinguished with only their serial (especially in
case a user has multiple sockets) might not be that helpful, discovered devices may be 
identified by the user.

When calling ``DiscoveredDevice/identify()`` on a ``DiscoveredDevice``, a connection
will be setup with the device and it's identify feature will be triggered (if supported),
which makes it status light blink for a couple of seconds.

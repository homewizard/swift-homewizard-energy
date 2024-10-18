# HomeWizard Energy: `HWLocalAPI`

Swift library to communicate with HomeWizard Energy devices using their local API.

This package is aimed at basic control of the device. Initial setup and configuration is assumed
to be done with the official HomeWizard Energy app.

[![Testing](https://github.com/homewizard/swift-homewizard-energy/actions/workflows/full-test.yml/badge.svg?branch=master)](https://github.com/homewizard/swift-homewizard-energy/actions/workflows/full-test.yml)
[![Swift 5.10](https://img.shields.io/badge/Swift-5.10-orange.svg?style=flat)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-14+-green.svg?style=flat)](http://developer.apple.com)
[![macOS](https://img.shields.io/badge/macOS-13+-green.svg?style=flat)](http://developer.apple.com)
[![watchOS](https://img.shields.io/badge/watchOS-7.0+-green.svg?style=flat)](http://developer.apple.com)
[![tvOS](https://img.shields.io/badge/tvOS-14.0+-green.svg?style=flat)](http://developer.apple.com)
[![Linux](https://img.shields.io/badge/Linux-Supported-green.svg?style=flat)](https://swift.org)
[![Release](https://img.shields.io/github/v/release/homewizard/swift-homewizard-energy)](https://github.com/homewizard/swift-homewizard-energy/releases)

- [Features](#features)
- [Usage](#usage)
  - [Discovery](#discovery)
    - [Monitor](#monitor)
    - [Quick Lookup](#quick-lookup)
  - [Devices](#devices)
    - [Simple Data and State](#simple-data-and-state)
    - [Monitoring](#monitoring)
- [Documentation](#documentation)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager-spm)
    - [Package File](#package-file)
    - [Xcode](#xcode)
- [Development & Contribution](#development-and-contribution)
- [Release Notes](#release-notes)
- [License](#license)

## Features

- [x] Discover HomeWizard Energy devices on your local network (not supported for Linux)
- [x] Connect to a device and fetch it's latest measurement readings
- [x] Control the power state of Energy Sockets
- [x] A `DeviceMonitor` that allows you to fetch all measurement data of one or more devices repetitively using a specified update interval

## Usage

This will briefly describe the usage.
A more detailed [documentation](#documentation) is added in the package.

### Discovery

You can use the `DeviceDiscoveryHandler` to discover HomeWizard Energy devices on your local network through Bonjour.

#### Monitor

To continuously monitor your network, you can implement its delegate:

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

#### Quick Lookup

Alternatively you can use a quick lookup to scan the network for just a couple of seconds and get the list with discovered devices:

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

### Devices

#### Simple Data and State

Once you have discovered a device, or know its IP address, you can load basic information of the device,
as well as getting its latest measurement data:

```swift
if let device = try await DeviceLoader.load("192.168.0.10") as? P1Meter {
    let measurement = try await device.fetchData()
    print("Current power usage: \(measurement.activePower) watt")
}
```

For Energy Sockets you can also get and set their state (power on/off, LED brightness, switch lock):

```swift
if let socket = try await DeviceLoader.load("192.168.0.10") as? EnergySocket {
    if try await socket.isPoweredOn {
        print("The socket was powered on. I will turn it off now...")
        try await socket.setPoweredOn(false)
    }
}
```

#### Monitoring

Besides getting measurement data manually as described above, you may also use the `DeviceMonitor` to continuously update the data
of one or more devices (with a specified update interval).

```swift
final class MyMonitor: Sendable {
    /// Devices to monitor
    private let devices: [any Device]

    init(devices: [any Device]) {
        self.devices = devices

        // Register the observer
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(dataReceived(_:)),
                name: DeviceMonitor.didUpdate,
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
        if let data = notification.userInfo?[DeviceMonitor.UserInfo.data] as? P1MeterData,
           let power = data.activePower {

            if power < 0 {
                print("You main connection is now delivering \(power) watt back into the grid")
            } else {
                print("You main connection is now using \(power) watt from the grid")
            }

        }
    }
}
```

## Documentation

The package is documented using [DocC](https://www.swift.org/documentation/docc/).

When added as a dependency to your project, use *Product > Build Documentation* (or ⌃⇧⌘D) once to
add it to your Developer Documentation.

## Installation

### Swift Package Manager (SPM)

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing Swift packages, both executables as libraries.
It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

#### Package File

Add HWLocalAPI as a package to your `Package.swift` file and then specify it as a dependency of the Target in which you wish to use it.

```swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MyProject",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/HomeWizard/swift-homewizard-energy", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyProject",
            dependencies: [
                .product(name: "HWLocalAPI", package: "swift-homewizard-energy")
            ]
        ),
        .testTarget(
            name: "MyProjectTests",
            dependencies: ["MyProject"]
        ),
    ]
)
```

#### Xcode

To add HWLocalAPI as a [dependency](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) to your Xcode project, 
select *File > Add Package Dependency* and enter the repository URL in the field top right.

## Development and contribution

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Release Notes

See [CHANGELOG.md](https://github.com/HomeWizard/swift-homewizard-energy/blob/master/CHANGELOG.md) for a list of changes.

## License

HWLocalAPI is available under the MIT license. See the LICENSE file for more info.

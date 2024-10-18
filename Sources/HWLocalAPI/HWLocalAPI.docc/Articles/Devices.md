# Devices

@Metadata {
    @PageImage(purpose: icon, source: "hw_logo_large")
}

Explanation of the different `Device` types provided by this package

## Overview

This article will explain the different device types that are being used/provided by this package.
Especially the difference and relation between a ``Device`` and a ``DiscoveredDevice`` is good to
know.

> Tip:
All devices (discovered or not) are uniquely identified by their `serial`

## Device vs DiscoveredDevice

- term DiscoveredDevice:
A ``DiscoveredDevice`` is a device discovered by Bonjour.
It only has some global info, like the ``DiscoveredDevice/type`` or whether the local API actually ``DiscoveredDevice/isAPIEnabled``.
It can't be used to 'connect to' or 'fetch data' from.
Since it's related to bonjour, this structure is not available for Linux.

- term Device:
A ``Device`` is an actual device object which can be used to communicate with and get data from.
Each supported HomeWizard Energy device has it's own structure based on this `Device` protocol.
(Since it's not related anymore to Bonjour, this object is available for Linux as well)

### Discovered devices

Discovered devices can be obtained using bonjour, as described in the <doc:Discovery> article.

Once you've got a discovered device, there are two ways to get the actual ``Device`` to work with:

- use the ``DiscoveredDevice/load()`` function on a discovered device
- use the ``DeviceLoader``'s ``DeviceLoader/load(_:)-7uvas`` function

Both methods will return a `Device` object of the correct type (e.g. `P1Meter` for a P1 meter, 
`EnergySocket` for an Energy Socket, etc)

### Devices

All supported HomeWizard Energy devices have their own structure conforming to the 
base ``Device`` protocol.

The following device types are currently support by this package:

- ``EnergySocket``
- ``KwhMeter``
- ``P1Meter``
- ``Watermeter``

Each device will have a `fetchData()` function to receive the latest measurement data of
that device.
Some devices like the ``P1Meter`` and ``EnergySocket`` will provide additional info.

> Note:
The local API for watermeters is only supported when powered by a USB-C adapter.

## Get a `Device` to work with

Devices can't be instantiated directly, they can only be 'loaded'.
Besides getting the basic device information when loading it, this also makes sure
you'll get the correct structure for a device, based on it's ``DeviceType``.

There are two main ways to load a device:

- term through a ``DiscoveredDevice``:
Use the ``DeviceLoader``'s ``DeviceLoader/load(_:)-7uvas`` passing the discovered device,
or directly by using the discovered device's ``DiscoveredDevice/load()`` function.

- term by its IP address:
Use the ``DeviceLoader``'s ``DeviceLoader/load(_:)-gasu`` passing the IP address, which can be
both an ipv4 as an ipv6 address.

> Note:
Since bonjour is not available for Linux, using the IP address will be the only way for Linux
to load a device.

## Local API

In case you want to work with the local API of a HomeWizard Energy device, you'll need to
(obviously) enable the device's local API using the Energy app on your smart phone.

Go to `Settings` - `Meters` - `your meter` and you can find the toggle at the bottom.
![Location of the local API switch](local-api-switch)

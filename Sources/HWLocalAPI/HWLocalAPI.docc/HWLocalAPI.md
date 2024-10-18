# ``HWLocalAPI``

@Metadata {
    @DisplayName("HWLocalAPI")
    @PageImage(purpose: icon, source: "hw_logo_large")
}

HomeWizard Energy Local API package for Swift

## Overview

A public Swift Package that can be used as a base dependency to work
with the 'local API' of HomeWizard Energy devices.

It supports discovering such devices through Bonjour (except for Linux)
as well as communicating with them and getting, for example, measurement data.

> Note:
To be able to connect to a HomeWizard Energy device, you must enable its local API
first by using the Energy app. The local API of watermeters will only be available
when they're powered by a USB-C cable.

## Topics

### Articles

- <doc:Devices>
- <doc:Discovery>
- <doc:Monitoring>

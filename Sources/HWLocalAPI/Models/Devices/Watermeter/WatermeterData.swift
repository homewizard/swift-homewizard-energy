
import Foundation

/**
 # WatermeterData

 Data points for the ``Watermeter``
 
 */
public struct WatermeterData: Codable, Sendable, DeviceData {
    /// The Wi-Fi network that the meter is connected to
    public let wifiSSID: String
    /// The strength of the Wi-Fi signal in %
    public let wifiStrength: Int

    /// Total water usage since installation in m3
    public let totalLiter: Double?
    /// Active water usage in liters per minute
    public let activeUsage: Double?

    private enum CodingKeys: String, CodingKey {
        case wifiSSID = "wifi_ssid"
        case wifiStrength = "wifi_strength"
        case totalLiter = "total_liter_m3"
        case activeUsage = "active_liter_lpm"
    }
}

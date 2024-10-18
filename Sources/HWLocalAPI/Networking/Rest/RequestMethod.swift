
import Foundation

public enum RequestMethod: String, Codable, Sendable {
    /// GET request
    case get = "GET"
    /// PUT request
    case put = "PUT"
    /// POST request
    case post = "POST"
    /// DELETE request
    case delete = "DELETE"
    /// PATCH request
    case patch = "PATCH"
}


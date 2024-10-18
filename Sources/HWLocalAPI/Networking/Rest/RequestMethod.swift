//
//  RequestMethod.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 17/10/2024.
//

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


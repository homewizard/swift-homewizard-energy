//
//  JSONDecoder+JSON.swift
//  HWLocalAPI
//
//  Created by Michiel Horvers on 04/10/2024.
//

import Foundation

internal extension JSONDecoder {
    /**
     Decode using the specified JSON object, instead of raw Data

     - parameter type: The type to decode
     - parameter json: The json object to use as input

     - returns: The decoded object (if successful)
     - throws
     */
    func decode<Object: Decodable>(_ type: Object.Type, from json: JSON) throws -> Object {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try self.decode(Object.self, from: data)
    }
}

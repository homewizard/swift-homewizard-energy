
import Foundation

#if os(Linux)
import FoundationNetworking
#else
import OSLog
#endif

// MARK: - Request Manager

/**
 # RequestManager

 Manager that can be used to handle http / REST requests

 ## Usage

 ### Base URL

 In case all of the requests you're going to perform will have the same prefix / base url,
 you may initialize an instance with that base url to reduce boilerplate code

 e.g.:

 ```swift
 let manager = RequestManager()
 let objects: [Object] = try await manager
    .performRequest(
      "https://10.10.10.10/API/v1/objects",
      method: .get
    )

 let data: Data = try await manager
    .performRequest(
      "https://10.10.10.10/API/v1/data",
      method: .get
    )
 ```

 v.s.:

 ```swift
 let manager = RequestManager(baseURL: "https://10.10.10.10/API/v1")

 let objects: [Object] = try await manager
    .performRequest(
      "/objects",
      method: .get
    )

 let data: Data = try await manager
    .performRequest(
      "/data",
      method: .get
    )
 ```

 ### Requests

 There are a number of request types available, which can be divided in the following groups, depending on the **Send** type:

 - **Generic**: Requests without a request body to send
 - **JSON**: Requests with a ``JSON`` body to send
 - **Object**: Requests with an `Encodable` object to send

 All of the request types within these groups can be further subdivided, depending on the **Receive** type, into:

 - **Object**: Expects to return a `Decodable` object
 - **JSON**: Expects to return a ``JSON`` dictionary
 - **Void**: Expects to return nothing

 Some examples to make it a bit clearer:

 The following code would want to _send JSON_ and _receive an object_:
 ```swift
 struct Person: Codable {
     var id: UUID?
     var name: String
     var age: Int

     static func fetch(id: UUID) async throws -> Person {
         try await RequestManager
             .default
             .performJSONRequest(
                 "https://example.com/load",
                 json: ["id": id],
                 method: .post
             )
     }
 }
 ```

 The following code would want to _send and receive an object_:
 ```swift
 struct Person: Codable {
     var id: UUID?
     var name: String
     var age: Int

     mutating func create() async throws {
         let response: Person = try await RequestManager
             .default
             .performObjectRequest(
                 "https://example.com/create",
                 object: self,
                 method: .put
             )

         self.id = response.id
     }
 }
 ```

 The following code doesn't want to _send nor receive anything_
 (e.g. you only care whether it fails or not):
 ```swift
 struct Device: Codable {
     var identifier: String

     func identify() async throws {
         try await RequestManager
             .default
             .performRequest(
                 "https://example.com/\(identifier)/identify",
                 method: .get
             )
     }
 }
 ```

 */
public final class RequestManager: Sendable {
    /**
     Default shared instance that can be used for quick requests
     where you don't need your own instance or a base url
     */
    public static let `default` = RequestManager()

    /**
     Base URL that is being used.

     When set, this will be put in front of all request URLs.

     e.g.:

     ```swift
     let manager = RequestManager()
     let objects: [Object] = try await manager
        .performRequest(
          "https://10.10.10.10/API/v1/objects",
          method: .get
        )

     let data: Data = try await manager
        .performRequest(
          "https://10.10.10.10/API/v1/data",
          method: .get
        )
     ```

     v.s.:

     ```swift
     let manager = RequestManager(baseURL: "https://10.10.10.10/API/v1")

     let objects: [Object] = try await manager
        .performRequest(
          "/objects",
          method: .get
        )

     let data: Data = try await manager
        .performRequest(
          "/data",
          method: .get
        )
     ```

     */
    public let baseURL: String

    #if !os(Linux)
    private let logger = Logger(subsystem: "nl.homewizard.HWLocalAPI", category: "Networking")
    #endif

    /**
     Initializes a new RequestManager

     When the `baseURL` has been set, it will be put in front
     of all requests for this instance

     - parameter baseURL: The base url to use (default: `""`)
     */
    public init(baseURL: String = "") {
        self.baseURL = baseURL
    }
}

// MARK: - Public Interface

public extension RequestManager {
    // MARK: JSON

    /**
     Performs a request, sending JSON and expecting a Decodable object as response

     - parameter url:       The request URL
     - parameter json:      The json to send
     - parameter method:    The request method to use
     - returns:             The request result
     - throws:              ``RequestError``
     */
    func performJSONRequest<Receive: Decodable>(_ url: String,
                                                json: JSON?,
                                                method: RequestMethod) async throws -> Receive {
        var body: Data?
        do {
            if let json, !json.isEmpty {
                body = try JSONSerialization.data(withJSONObject: json)
            }
        } catch {
            throw RequestError(.encodingError, originated: error, data: nil, message: "Failed plain JSON encoding")
        }

        return try await self.doRequest(url, body: body, method: method)
    }

    /**
     Performs a request, sending JSON and expecting JSON as response

     - parameter url:       The request URL
     - parameter json:      The json to send
     - parameter method:    The request method to use
     - returns:             The request result
     - throws:              ``RequestError``
     */
    func performJSONRequest(_ url: String, json: JSON?, method: RequestMethod) async throws -> JSON {
        var body: Data?

        do {
            if let json, !json.isEmpty {
                body = try JSONSerialization.data(withJSONObject: json)
            }
        } catch {
            throw RequestError(.encodingError, originated: error, data: nil, message: "Failed plain JSON encoding")
        }

        let data: Data = try await self.doRequest(url, body: body, method: method)

        do {
            let obj = try JSONSerialization.jsonObject(with: data)
            guard let json = obj as? JSON else {
                throw RequestError(.decodingError, message: "Unexpected JSON serialization outcome")
            }
            return json

        } catch {
            throw RequestError(.decodingError, originated: error, message: "Failed JSON decoding")
        }
    }

    /**
     Performs a request, sending JSON and expecting no response

     - parameter url:       The request URL
     - parameter json:      The json to send
     - parameter method:    The request method to use
     - throws:              ``RequestError``
     */
    func performVoidJSONRequest(_ url: String, json: JSON?, method: RequestMethod) async throws {
        let _: Data = try await self.performJSONRequest(url, json: json, method: method)
    }

    // MARK: Objects

    /**
     Performs a request, sending an `Encodable` object as body and expecting a `Decodable` object as response

     - parameter url:       The request URL
     - parameter object:    The object to send
     - parameter method:    The request method to use
     - returns:             The request result
     - throws:              ``RequestError``
     */
    func performObjectRequest<Send: Encodable, Receive: Decodable>(_ url: String,
                                                                   object: Send,
                                                                   method: RequestMethod) async throws -> Receive {
        let body: Data
        do {
            body = try JSONEncoder().encode(object)
        } catch {
            throw RequestError(.encodingError, originated: error, message: "Failed object encoding")
        }

        return try await self.doRequest(url, body: body, method: method)
    }

    /**
     Performs a request, sending an `Encodable` object and expecting no response

     - parameter url:       The request URL
     - parameter object:    The object to send
     - parameter method:    The request method to use
     - throws:              ``RequestError``
     */
    func performVoidObjectRequest<Send: Encodable>(_ url: String,
                                                   object: Send,
                                                   method: RequestMethod) async throws {
        let _: Data = try await self.performObjectRequest(url, object: object, method: method)
    }

    // MARK: Generic

    /**
     Performs a request, without a body and expecting a `Decodable` object as response

     - parameter url:       The request URL
     - parameter method:    The request method to use
     - throws:              ``RequestError``
     */
    func performRequest<Receive: Decodable>(_ url: String,
                                            method: RequestMethod) async throws -> Receive {
        try await self.doRequest(url, body: nil, method: method)
    }

    /**
     Performs a request, without a body and expecting no response

     - parameter url:       The request URL
     - parameter method:    The request method to use
     - throws:              ``RequestError``
     */
    func performRequest(_ url: String, method: RequestMethod) async throws {
        let _: Data = try await self.doRequest(url, body: nil, method: method)
    }
}

// MARK: - Private Handle

private extension RequestManager {
    /**
     All public requests will eventually fall down into this handler

     - parameter url: The request url
     - parameter body: Optional request body
     - parameter method: The http method
     - returns: The request result
     - throws: RequestError
     */
    func doRequest<Receive: Decodable>(_ url: String, body: Data?, method: RequestMethod) async throws -> Receive {
        /*
         Logging
         */

        // Sequencer so the logging will make it clear
        // which response belongs to which request
        let sequence = await Sequencer.next

        #if !os(Linux)
        self.logger.log(level: .debug, "[\(sequence, privacy: .public)] Starting request for \(method.rawValue, privacy: .public) \(self.baseURL + url, privacy: .private)")
        #endif

        /*
         Prepare the request
         */

        // Verify the specified URL
        guard let requestURL = URL(string: baseURL + url) else {
            logFinish(sequence: sequence, response: nil, error: RequestError(.invalidURL))
            throw RequestError(.invalidURL)
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue

        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let session = URLSession.shared

        /*
         Start the task
         */

        var data: Data?
        var response: URLResponse?
        let start = DispatchTime.now()

        do {
            let (receivedData, receivedResponse) = try await session.data(for: request)
            data = receivedData
            response = receivedResponse

        } catch {
            let toThrow = RequestError(.other, originated: error)
            logFinish(sequence: sequence, response: response, error: toThrow, start: start)
            throw toThrow
        }

        /*
         Response Handling
         */

        // Check if the response isn't an error
        if let error = RequestError(response, data: data) {
            logFinish(sequence: sequence, response: response, data: data, error: error, start: start)
            throw error
        }

        // Check if we have data and decode when applicable
        if let data {
            // When the caller expects `Data` as response, don't decode it and just return the response data
            if Receive.self == Data.self {
                logFinish(sequence: sequence, response: response, data: data, start: start)
                return data as! Receive

            } else {
                // Otherwise try to decode to the expected type
                do {
                    let result = try JSONDecoder().decode(Receive.self, from: data)
                    logFinish(sequence: sequence, response: response, data: data, start: start)
                    return result

                } catch {
                    logFinish(sequence: sequence, response: response, data: data, error: error, start: start)
                    throw RequestError(.decodingError, originated: error)
                }
            }

        } else {
            // No Data, no Error
            let toThrow = RequestError(.unexpectedResponse, message: "No data nor an error")
            logFinish(sequence: sequence, response: response, data: data, error: toThrow, start: start)
            throw toThrow
        }
    }

    /**
     Log the 'finished' message

     - parameter sequence:  The sequence that has been finished
     - parameter response:  The received URLResponse
     - parameter data:      The received data
     - parameter error:     Error that occurred
     - parameter start:     Start time of the request
     */
    func logFinish(sequence: Int, response: URLResponse?, data: Data? = nil, error: Error? = nil, start: DispatchTime? = nil) {
        #if !os(Linux)
        var httpCode = ""
        if let response = response as? HTTPURLResponse {
            httpCode = "\(response.statusCode)"
        }

        var size = ""
        if let data {
            size = " \(data.count)b"
        }

        var msec = ""
        if let start {
            let ms = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
            msec = " \(ms)ms"
        }

        if let error {
            self.logger.log("[\(sequence, privacy: .public)] FAILED \(httpCode, privacy: .public) \(error, privacy: .public)")
        } else {
            self.logger.log(level: .debug, "[\(sequence, privacy: .public)] Success \(httpCode, privacy: .public)\(size, privacy: .public)\(msec, privacy: .public)")
        }
        #endif
    }
}

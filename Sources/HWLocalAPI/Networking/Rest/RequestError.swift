
import Foundation

#if os(Linux)
import FoundationNetworking
#endif

public struct RequestError: Error {
    // MARK: - ErrorKind
    public enum ErrorKind: Int, Sendable {

        // MARK: Custom Errors

        /// Other Error
        /// Originated error should contain the originated error and optionally error data may be set
        case other = 900
        /// Invalid URL
        case invalidURL = 901
        /// Encoding Error
        /// Originated error should contain an encoding error
        case encodingError = 902
        /// Decoding Error
        /// Originated error should contain a decoding error
        case decodingError = 903
        /// We've received an unexpected response
        /// Message should give some more details
        case unexpectedResponse = 907
        /// Not Ready Error
        /// Message should be set, describing who/what is not ready
        case notReady = 904

        // MARK: NSURL Errors

        /// Request Timeout
        case requestTimeout = -1001
        /// Unknown Host
        case unknownHost = -1003
        /// Unable to connect to server
        /// (probably offline)
        case unableToConnectToServer = -1004
        /// Network connection lost
        case networkConnectionLost = -1005
        /// No Internet
        case noInternet = -1009
        /// SSL error
        case sslError = -1200
        /// Invalid SSL certificate
        case invalidCertificate = -1202

        // MARK: HTTP Errors

        /// 400 status code: Programmer fault
        case badRequestError = 400
        /// 401 status code: Invalid Authentication
        case unAuthorizedError = 401
        /// 403 status code: No access
        case accessForbiddenError = 403
        /// 404 status code: Not found
        case notFoundError = 404
        /// 405 status code: Method not allowed
        case methodNotAllowedError = 405
        /// 409 status code: The data already exists
        case conflictError = 409
        /// 412 status code: A required parameter has not been provided
        case preconditionFailedError = 412
        /// 415 status code: Unsupported Media Type
        case unsupportedMediaTypeError = 415
        /// 422 status code: Validation of post message has failed (invalid email format for example)
        case validationError = 422
        /// 424 status code: Failed Dependency
        case failedDependencyError = 424
        /// 500 status code: Server could not handle te request
        case internalServerError = 500
        /// 502 Handling communication with the endpoint (ex: LED) failed
        case badGatewayError = 502
        /// 503 status code: Endpoint is offline
        case serverUnavailableError = 503
        /// 504 status code: Device failed to respond (got this also when you post a request with wrong arguments)}
        case gatewayTimeOutError = 504
    }

    // MARK: - Public properties

    /// Kind of the error
    public let kind: ErrorKind

    /// Optional originated error (e.g. when the error kind is `.other`)
    public let originatedError: Error?

    /// Optional data related to the error
    /// (e.g. if a request fails but the remote did send data together with an error status code)
    public let errorData: Data?

    /// Optional message describing the error (e.g. when the error kind is `.notReady`)
    public let message: String?

    // MARK: - Initializers
    
    /**
     Initiates a new RequestError

     - parameter kind:       The error kind
     - parameter originated: Optional originated Error (Default: nil)
     - parameter data:       Optional data related to the error (Default: nil)
     - parameter message:    Optional message describing the error (Default: nil)
     */
    public init(_ kind: ErrorKind, originated: Error? = nil, data: Data? = nil, message: String? = nil) {
        // Check the originated error first,
        // in case we could map an NSURL error
        if let nsurlError = originated as? NSError,
            nsurlError.domain == NSURLErrorDomain,
            let nsurlKind = ErrorKind(rawValue: nsurlError.code) {
            self.kind = nsurlKind

        } else {
            self.kind = kind
        }

        self.originatedError = originated
        self.errorData = data
        self.message = message
    }

    /**
     Checks if the status code is an error code.
     If so, it will return the related error, otherwise just `nil`

     - parameter response: The URLResponse
     - parameter data: Optional data retrieved
     */
    public init?(_ response: URLResponse?, data: Data?) {
        guard let response = response as? HTTPURLResponse else { return nil }
        guard let kind = ErrorKind(rawValue: response.statusCode) else { return nil }

        self.kind = kind
        self.errorData = data
        self.originatedError = nil
        self.message = nil
    }
}

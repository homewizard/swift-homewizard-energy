
#if os(Linux)

import Foundation
import FoundationNetworking

public extension URLSession {
    func data(for request: URLRequest) async throws -> (Data?, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in

                if let error = error {
                    return continuation.resume(throwing: error)
                }

                guard let response = response as? HTTPURLResponse else {
                    return continuation.resume(throwing: RequestError(.unexpectedResponse, message: "Missing URL Response"))
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}

#endif

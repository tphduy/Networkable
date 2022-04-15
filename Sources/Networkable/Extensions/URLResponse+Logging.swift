//
//  URLResponse+Logging.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

extension URLResponse {
    /// Return a `String` representing itself.
    /// - Returns: A `String` if the `url` is valid, otherwise, an emty `String`.
    public func logging() -> String {
        guard let url = self.url else { return "" }
        let title = "📩 Response: \(url.absoluteString)"
        guard let response = self as? HTTPURLResponse else { return title }
        let statusCode = "-H \(response.statusCode)"
        let headers = response.allHeaderFields
            .map { "-H \"\($0): \($1)\"" }
            .sorted()
        let result = ([title, statusCode] + headers).joined(separator: "\n    ")
        return result
    }
}

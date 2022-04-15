//
//  URLRequest+Logging.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

extension URLRequest {
    /// Return a `String` representing itself.
    /// - Returns: A `String` if the `url` is valid, otherwise, an emty `String`.
    public func logging() -> String {
        guard let url = url else { return "" }
        let title =  "🚀 Request: \(url.absoluteString)"
        let method = httpMethod.map { "-X \($0)" }
        let headers = allHTTPHeaderFields?
            .map { "-H \"\($0)\": \"\($1)\"" }
            .sorted() ?? []
        let body = httpBody
            .map { String(data: $0, encoding: .utf8) }?
            .map { "-d \"\($0)\"" }
        let result = ([title, method] + headers + [body])
            .compactMap { $0 }
            .joined(separator: "\n    ")
        return result
    }
}

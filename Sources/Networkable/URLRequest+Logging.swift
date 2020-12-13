//
//  URLRequest+Logging.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

extension URLRequest {
    
    /// Create a string re-presenting itself.
    /// - Returns: A string re-presenting itself.
    public func logging() -> String {
        guard let url = url else { return "" }

        var components = ["🚀 Request: \(url.absoluteString)"]

        if let method = httpMethod {
            components.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for header in headers {
                components.append("-H \"\(header.key)\": \"\(header.value)\"")
            }
        }

        if let httpBody = httpBody, let value = String(data: httpBody, encoding: .utf8) {
            components.append("-d \"\(value)\"")
        }

        return components.joined(separator: "\n\t")
    }
}

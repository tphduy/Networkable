//
//  URLResponse+Logging.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

extension URLResponse {
    
    /// Create a string re-presenting itself.
    /// - Returns: A string re-presenting a itself.
    public func logging() -> String {
        guard let url = self.url else { return "" }
        var components = ["📩 Response: \(url.absoluteString)"]
        if let response = self as? HTTPURLResponse {
            components.append("-H \(response.statusCode)")
            for header in response.allHeaderFields {
                components.append("-H \"\(header.key): \(header.value)\"")
            }
        }

        return components.joined(separator: "\n\t")
    }
}

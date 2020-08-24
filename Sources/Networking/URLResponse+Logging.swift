//
//  URLResponse+Logging.swift
//  Networking
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

extension URLResponse {
    public func logging() -> String {
        guard let url = self.url else {
            return ""
        }

        var components = ["📩 Response: \(url.absoluteString)"]

        if let response = self as? HTTPURLResponse {
            components.append("-H \(response.statusCode)")

            for header in response.allHeaderFields {
                components.append("-H \"\(header.key): \(header.value)\"")
            }
        }

        return components.joined(separator: " \n\t")
    }
}

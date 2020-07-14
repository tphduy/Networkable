//
//  URLRequest+Logging.swift
//  Networking
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

extension URLRequest {
    public func logging() -> String {
        guard let url = url, let method = httpMethod else {
            return ""
        }

        var components = ["curl -v"]

        components.append("-X \(method)")

        if let headers = allHTTPHeaderFields {
            for header in headers {
                components.append("-H \"\(header.key)\": \"\(header.value)\"")
            }
        }

        if let httpBody = httpBody, let value = String(data: httpBody, encoding: .utf8) {
            components.append("-d \"\(value)\"")
        }

        components.append("\"\(url.absoluteString)\"")

        return components.joined(separator: " \n\t")
    }
}

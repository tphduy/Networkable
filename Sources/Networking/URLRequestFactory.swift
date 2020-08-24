//
//  URLRequestFactory.swift
//  Networking
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

public protocol URLRequestFactory {
    var host: String { get }
    func make(endpoint: Endpoint) throws -> URLRequest
}

public struct DefaultURLRequestFactory: URLRequestFactory {
    public let host: String

    public init(host: String) {
        self.host = host
    }

    public func make(endpoint: Endpoint) throws -> URLRequest {
        guard var url = URL(string: host) else {
            throw NetworkingError.invalidURL(host)
        }
        url.appendPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = endpoint.headers
        request.httpMethod = endpoint.method.rawValue.uppercased()
        request.httpBody = try endpoint.body()
        return request
    }
}

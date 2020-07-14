//
//  URLRequestFactory.swift
//  Networking
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

public protocol URLRequestFactory {
    var rawURL: String { get }
    func make(endpoint: Enpoint) throws -> URLRequest
}

public struct DefaultURLRequestFactory: URLRequestFactory {
    public let rawURL: String

    public init(rawURL: String) {
        self.rawURL = rawURL
    }

    public func make(endpoint: Enpoint) throws -> URLRequest {
        guard var url = URL(string: rawURL) else {
            throw NetworkingError.invalidURL(rawURL)
        }
        url.appendPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = endpoint.headers
        request.httpMethod = endpoint.method.rawValue.uppercased()
        request.httpBody = try endpoint.body()
        return request
    }
}

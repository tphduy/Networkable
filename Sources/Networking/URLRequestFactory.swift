//
//  URLRequestFactory.swift
//  Networking
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

public protocol URLRequestFactory {
    var host: String { get set }
    var cachePolicy: URLRequest.CachePolicy { get set }
    func make(endpoint: Endpoint) throws -> URLRequest
}

public struct DefaultURLRequestFactory: URLRequestFactory {
    public var host: String
    public var cachePolicy: URLRequest.CachePolicy

    public init(
        host: String,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) {
        self.host = host
        self.cachePolicy = cachePolicy
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

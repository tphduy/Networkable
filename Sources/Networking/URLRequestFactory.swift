//
//  URLRequestFactory.swift
//  Networking
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

public protocol URLRequestFactory {
    
    func make(endpoint: Endpoint) throws -> URLRequest
    
    func make(
        endpoint: Endpoint,
        cachePolicy: URLRequest.CachePolicy,
        timeoutInterval: TimeInterval) throws -> URLRequest
}

public struct DefaultURLRequestFactory: URLRequestFactory {
    
    public var host: String
    
    public init(host: String) {
        self.host = host
    }

    public func make(endpoint: Endpoint) throws -> URLRequest {
        try self.make(
            endpoint: endpoint,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 60)
    }
    
    public func make(
        endpoint: Endpoint,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60) throws -> URLRequest {
        guard var url = URL(string: host) else {
            throw NetworkingError.invalidURL(host)
        }
        url.appendPathComponent(endpoint.path)
        var request = URLRequest(
            url: url,
            cachePolicy: cachePolicy,
            timeoutInterval: timeoutInterval)
        request.allHTTPHeaderFields = endpoint.headers
        request.httpMethod = endpoint.method.rawValue.uppercased()
        request.httpBody = try endpoint.body()
        return request
    }
}

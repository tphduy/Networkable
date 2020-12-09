//
//  URLRequestFactory.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// The object that constructs the request.
public protocol URLRequestFactory {
    
    /// The base URL  (or host)  for  the request.
    var baseURL: String { get set }
    
    /// The cache policy for the request.
    var cachePolicy: URLRequest.CachePolicy { get set }
    
    /// The timeout interval for the request.
    var timeoutInterval: TimeInterval { get set }
    
    /// Creates and initializes a URL request with the given endpoint.
    /// - Parameter endpoint: the endpoint of the request.
    func make(endpoint: Endpoint) throws -> URLRequest
}

/// A default implementation of `URLRequestFactory`.
public struct DefaultURLRequestFactory: URLRequestFactory {
    
    public var baseURL: String
    public var cachePolicy: URLRequest.CachePolicy
    public var timeoutInterval: TimeInterval
    
    public init(
        baseURL: String,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60) {
        self.baseURL = baseURL
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }
    
    public func make(endpoint: Endpoint) throws -> URLRequest {
        let rawURL = baseURL + endpoint.path
        
        guard
            let url = URL(string: rawURL)
        else {
            throw NetworkableError.invalidURL(rawURL)
        }
        
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

//
//  URLRequestBuilder.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// An object that constructs an HTTP request.
public struct URLRequestBuilder: URLRequestBuildable {
    // MARK: Dependencies
    
    public var baseURL: URL?
    
    public var cachePolicy: URLRequest.CachePolicy
    
    public var timeoutInterval: TimeInterval
    
    // MARK: Init
    
    /// An object that constructs an HTTP request.
    /// - Parameters:
    ///   - baseURL: The base URL of the request. The default value is `nil`.
    ///   - cachePolicy: An enum specifies the interaction with the cached responses. The default value is `useProtocolCachePolicy`.
    ///   - timeoutInterval: The timeout interval in seconds for the request. The default value is `60`.
    public init(
        baseURL: URL? = nil,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60
    ) {
        self.baseURL = baseURL
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }
    
    // MARK: URLRequestBuildable
    
    /// Creates and initializes a URL request with the given endpoint. If the URL of the endpoint is absolute, the base URL takes no effect.
    /// - Parameter endpoint: The endpoint of the request.
    /// - Throws: `NetworkableError.invalidURL` if the URL of the endpoint is invalid
    /// - Returns: An URL request.
    public func build(endpoint: Endpoint) throws -> URLRequest {
        guard
            let url = URL(string: endpoint.url, relativeTo: baseURL)
        else {
            throw NetworkableError.invalidURL(endpoint.url, relativeURL: baseURL)
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

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
    
    /// The base URL of the request.
    ///
    /// Example: https://api.foo.bar/v1.
    public var baseURL: URL?
    
    /// An enum specifies the interaction with the cached responses.
    public var cachePolicy: URLRequest.CachePolicy
    
    /// The timeout interval in seconds for the request.
    ///
    /// If during a connection attempt the request remains idle for longer than the timeout interval, the request is considered to have timed out.
    public var timeoutInterval: TimeInterval
    
    // MARK: Init
    
    /// Initiate a builder that constructs an HTTP request.
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
    
    public func build(request: Request) throws -> URLRequest {
        guard let url = URL(string: request.url, relativeTo: baseURL) else {
            throw NetworkableError.invalidURL(request.url, relativeURL: baseURL)
        }
        var result = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        result.allHTTPHeaderFields = request.headers
        result.httpMethod = request.method.rawValue.uppercased()
        result.httpBody = try request.body()
        return result
    }
}

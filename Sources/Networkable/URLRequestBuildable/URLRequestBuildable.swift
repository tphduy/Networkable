//
//  URLRequestBuildable.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// An object that constructs an HTTP request.
public protocol URLRequestBuildable {
    /// The base URL of the request.
    ///
    /// Example: https://api.foo.bar/v1.
    var baseURL: URL? { get set }
    
    /// An enum specifies the interaction with the cached responses.
    var cachePolicy: URLRequest.CachePolicy { get set }
    
    /// The timeout interval in seconds for the request.
    ///
    /// If during a connection attempt the request remains idle for longer than the timeout interval, the request is considered to have timed out.
    var timeoutInterval: TimeInterval { get set }
    
    /// Build an HTTP URL request with the given endpoint.
    /// - Parameter endpoint: An object abstracts an endpoint of an HTTP request.
    func build(endpoint: Endpoint) throws -> URLRequest
}

//
//  URLRequestBuildable.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// The object that constructs a request.
public protocol URLRequestBuildable {
    
    /// The base URL of the request.
    var baseURL: URL? { get set }
    
    /// The cache policy for the request.
    var cachePolicy: URLRequest.CachePolicy { get set }
    
    /// The timeout interval for the request.
    var timeoutInterval: TimeInterval { get set }
    
    /// Creates and initializes a URL request with the given endpoint.
    /// - Parameter endpoint: The endpoint of the request.
    func build(endpoint: Endpoint) throws -> URLRequest
}

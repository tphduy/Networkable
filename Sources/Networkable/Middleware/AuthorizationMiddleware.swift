//
//  Authorization.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

// MARK: - AuthorizationMiddleware

/// A middleware authorizees outgoing request
public struct AuthorizationMiddleware: Middleware {
    
    /// A place within a request where authorization materials will be placed
    public enum Place: Equatable, Hashable {
        
        /// The request's header
        case header
        
        /// The query components of request's URL
        case query
    }
    
    // MARK: - Dependencies

    /// The key of authorization material
    public var key: String
    
    /// The authorization material
    public var value: String
    
    /// A place within a request where authorization materials will be placed
    public var place: Place
    
    // MARK: - Init
    
    /// Create a middleware authorizees outgoing request
    /// - Parameters:
    ///   - key: The key of authorization material
    ///   - value: The authorization material
    ///   - place: A place within a request where authorization materials will be placed
    public init(
        key: String,
        value: String,
        place: Place = .header) {
        self.key = key
        self.value = value
        self.place = place
    }
    
    // MARK: - Middleware

    public func prepare(request: URLRequest) throws -> URLRequest {
        let authorizedRequest = self.authorize(request: request)
        return authorizedRequest
    }
    
    public func willSend(request: URLRequest) {}
    
    public func didReceive(response: URLResponse, data: Data) throws {}
    
    // MARK: - Main
    
    /// Create an authorized request from the origin request
    /// - Parameter request: The original request
    /// - Returns: An authorized request
    public func authorize(request: URLRequest) -> URLRequest {
        guard
            !key.isEmpty,
            !value.isEmpty
        else { return request }

        var request = request

        switch place {
        case .header:
            request.addValue(value, forHTTPHeaderField: key)
        case .query:
            guard
                let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else { break }
            
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems = (components.queryItems ?? []) + [queryItem]
            request.url = components.url
        }

        return request
    }
}

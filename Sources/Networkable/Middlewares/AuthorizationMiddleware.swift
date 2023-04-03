//
//  Authorization.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

/// A middleware that authorizes an outgoing request.
public struct AuthorizationMiddleware: Middleware {
    
    /// A type that defines a list of places to append the authorization components.
    public enum Place: Equatable, Hashable {
        /// The request's header.
        case header
        
        /// The query components of the request's URL.
        case query
    }
    
    // MARK: Dependencies

    /// The key that specifies the authorization components.
    public var key: String
    
    /// The authorization component.
    public var value: String
    
    /// A place where the authorization components will be added within a request.
    public var place: Place
    
    // MARK: Init
    
    /// Initiates a middleware that authorizes an outgoing request.
    /// - Parameters:
    ///   - key: The key that specifies the authorization components.
    ///   - value: The authorization component.
    ///   - place: A type that defines a list of places to append the authorization components. The default value is `.header`
    public init(
        key: String,
        value: String,
        place: Place = .header
    ) {
        self.key = key
        self.value = value
        self.place = place
    }
    
    // MARK: Utilities
    
    /// Returns an authorized request from the origin request.
    /// - Parameter request: A URL load request that is independent of protocol or URL scheme.
    /// - Returns: An authorized URL load request that is independent of protocol or URL scheme.
    func authorize(request: URLRequest) -> URLRequest {
        // Verifies the key and values are not empty.
        guard
            !key.isEmpty,
            !value.isEmpty
        else {
            // Return the result.
            return request
        }
        // Appends the authorization components.
        var result = request
        switch place {
        case .header:
            // Appends to request's header.
            result.addValue(value, forHTTPHeaderField: key)
        case .query:
            // Verifies the URL of request are valid.
            guard
                let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else {
                break
            }
            // Appends to the request's query items.
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems = (components.queryItems ?? []) + [queryItem]
            result.url = components.url
        }
        // Return the result.
        return result
    }
    
    // MARK: Middleware

    public func prepare(request: URLRequest) throws -> URLRequest {
        authorize(request: request)
    }
    
    public func willSend(request: URLRequest) {}
    
    public func didReceive(response: URLResponse, data: Data) throws {}
    
    public func didReceive(error: Error, of request: URLRequest) {}
}

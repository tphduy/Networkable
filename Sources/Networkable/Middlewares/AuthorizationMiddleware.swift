//
//  Authorization.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

/// A middleware authorizes an outgoing request.
public struct AuthorizationMiddleware: Middleware {
    
    /// An enum abstracts where the authorization components will be added within a request.
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
    
    /// Initiate a middleware authorizes an outgoing request.
    /// - Parameters:
    ///   - key: The key that specifies the authorization components.
    ///   - value: The authorization component.
    ///   - place: A place where the authorization components will be added within a request. The default value is `.header`
    public init(
        key: String,
        value: String,
        place: Place = .header
    ) {
        self.key = key
        self.value = value
        self.place = place
    }
    
    // MARK: Middleware

    public func prepare(request: URLRequest) throws -> URLRequest {
        authorize(request: request)
    }
    
    public func willSend(request: URLRequest) {}
    
    public func didReceive(response: URLResponse, data: Data) throws {}
    
    // MARK: Utilities
    
    /// Return an authorized request from the origin request.
    /// - Parameter request: An object abstracts information about the request.
    /// - Returns: A request with embedded authorization components.
    func authorize(request: URLRequest) -> URLRequest {
        guard !key.isEmpty, !value.isEmpty else { return request }
        var result = request
        switch place {
        case .header:
            result.addValue(value, forHTTPHeaderField: key)
        case .query:
            guard let url = request.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { break }
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems = (components.queryItems ?? []) + [queryItem]
            result.url = components.url
        }
        return result
    }
}

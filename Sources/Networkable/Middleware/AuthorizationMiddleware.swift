//
//  Authorization.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

// MARK: - AuthorizationType

public enum AuthorizationPlace: Equatable, Hashable {
    
    case header, query
}

public protocol AuthorizationType {
    
    var key: String { get }
    var value: String { get }
    var place: AuthorizationPlace { get }
}

public struct DefaultAuthorizationType: AuthorizationType, Equatable, Hashable {
    
    public let key: String
    public let value: String
    public let place: AuthorizationPlace

    public init(
        key: String,
        value: String,
        place: AuthorizationPlace = .header) {
        self.key = key
        self.value = value
        self.place = place
    }
}

// MARK: - AuthorizationMiddleware

public protocol AuthorizationMiddleware: Middleware {
    
    func authorize(request: URLRequest) -> URLRequest
}

public struct DefaultAuthorizationMiddleware: AuthorizationMiddleware {
    
    public let authorization: () -> AuthorizationType

    public init(authorization: @escaping () -> AuthorizationType) {
        self.authorization = authorization
    }

    public func authorize(request: URLRequest) -> URLRequest {
        let authorization = self.authorization()
        guard !authorization.key.isEmpty, !authorization.value.isEmpty else { return request }

        var request = request

        switch authorization.place {
        case .header:
            request.addValue(authorization.value, forHTTPHeaderField: authorization.key)
        case .query:
            guard
                let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                else { break }
            let queryItem = URLQueryItem(name: authorization.key, value: authorization.value)
            components.queryItems = (components.queryItems ?? []) + [queryItem]
            request.url = components.url
        }

        return request
    }

    public func prepare(request: URLRequest) throws -> URLRequest {
        return self.authorize(request: request)
    }
    
    public func willSend(request: URLRequest) {}
    
    public func didReceive(response: URLResponse, data: Data) throws {}
}

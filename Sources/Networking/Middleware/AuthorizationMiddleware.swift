//
//  Authorization.swift
//  Networking
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
    var authorization: AuthorizationType { get }
    func authorize(request: URLRequest) -> URLRequest
}

public struct DefaultAuthorizationMiddleware: AuthorizationMiddleware {
    public let authorization: AuthorizationType

    public init(authorization: AuthorizationType) {
        self.authorization = authorization
    }

    public func authorize(request: URLRequest) -> URLRequest {
        var request = request
        
        switch authorization.place {
        case .header:
            request.addValue(authorization.value, forHTTPHeaderField: authorization.key)
        case .query:
            let query = authorization.key + "=" + (authorization.value)
            let url = URL(string: query, relativeTo: request.url)
            request.url = url
        }
    
        return request
    }

    public func prepare(request: URLRequest) throws -> URLRequest {
        let authorizedRequest = self.authorize(request: request)
        return authorizedRequest
    }
}

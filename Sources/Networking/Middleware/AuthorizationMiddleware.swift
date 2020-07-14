//
//  Authorization.swift
//  Networking
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

// MARK: - AuthorizationType

public protocol AuthorizationType {
    var key: String { get }
    var value: String { get }
}

public enum DefaultAuthorizationType: AuthorizationType {
    case api(key: String, value: String)
    case bearer(token: String)

    public var key: String {
        switch self {
        case let .api(key, _): return key
        case .bearer: return "Bearer "
        }
    }

    public var value: String {
        switch self {
        case let .api(_, value): return value
        case let .bearer(token): return token
        }
    }
}

// MARK: - AuthorizationMiddleware

public protocol AuthorizationMiddleware: Middleware {
    var type: AuthorizationType { get }
    func authorize(request: URLRequest) -> URLRequest
}

public struct DefaultAuthorizationMiddleware: AuthorizationMiddleware {
    public let type: AuthorizationType

    public init(type: AuthorizationType) {
        self.type = type
    }

    public func authorize(request: URLRequest) -> URLRequest {
        var request = request
        request.addValue(type.value, forHTTPHeaderField: type.key)
        return request
    }

    public func prepare(request: URLRequest) throws -> URLRequest {
        let authorizedRequest = self.authorize(request: request)
        return authorizedRequest
    }
}

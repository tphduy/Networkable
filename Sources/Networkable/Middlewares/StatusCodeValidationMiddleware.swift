//
//  StatusCodeValidationMiddleware.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

/// A middleware validate a response by the response's status code
public struct StatusCodeValidationMiddleware: Middleware {
    
    // MARK: - Dependencies
    
    /// acceptable status code range
    public let acceptableStatusCodes: ResponseStatusCodes
    
    // MARK: - Init
    
    /// Creates a middleware validate a response by the response's status code
    /// - Parameter acceptableStatusCodes: The range of acceptable status codes.
    public init(acceptableStatusCodes: ResponseStatusCodes = .success) {
        self.acceptableStatusCodes = acceptableStatusCodes
    }
    
    // MARK: - Middleware
    
    public func prepare(request: URLRequest) throws -> URLRequest {
        return request
    }
    
    public func willSend(request: URLRequest) {}
    
    public func didReceive(response: URLResponse, data: Data) throws {
        try validate(response: response)
    }
    
    // MARK: - Main
    
    /// Validate a response whether it is a HTTP response and its status code is acceptable
    /// - Parameter response: The response to validate, it's must be a HTTP response.
    /// - Throws:
    ///     - An unexpected response error if the response is not HTTP response
    ///     - An unacceptable code error if the response's status code is not acceptable
    public func validate(response: URLResponse) throws {
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkableError.unexpectedResponse(response)
        }
        
        guard acceptableStatusCodes.contains(code) else {
            throw NetworkableError.unacceptableStatusCode(code, response)
        }
    }
}

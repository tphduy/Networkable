//
//  StatusCodeValidationMiddleware.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

/// A middleware determines whether a response is valid by verifying its status code.
public struct StatusCodeValidationMiddleware: Middleware {
    // MARK: Dependencies
    
    /// A range of HTTP response status codes that specifies a response is valid.
    public var acceptableStatusCodes: ResponseStatusCodes
    
    // MARK: Init
    
    /// Initiates a middleware determines whether a response is valid by verifying its status code.
    /// - Parameter acceptableStatusCodes: A range of HTTP response status codes that specifies a response is valid.
    public init(acceptableStatusCodes: ResponseStatusCodes = .success) {
        self.acceptableStatusCodes = acceptableStatusCodes
    }
    
    // MARK: Utilities
    
    /// Validates a response whether it is an HTTP response and its status code is acceptable.
    /// - Parameters:
    ///   - response: The metadata associated with the response to a URL load request, independent of protocol and URL scheme. It's must be an instance of `HTTPURLResponse`.
    ///   - data: The data that was returned by the server.
    /// - Throws: An unexpected response error if the response is not an HTTP response, or an unacceptable code error if the response's status code is unacceptable.
    func validate(response: URLResponse, data: Data) throws {
        // Verifies the response is an instance of `HTTPURLResponse`.
        guard let response = response as? HTTPURLResponse else {
            // Throws an unexpected response.
            throw NetworkableError.unexpectedResponse(response, data)
        }
        // Verifies the status code of response is acceptable.
        guard acceptableStatusCodes.contains(response.statusCode) else {
            // Throws an unacceptable status code error.
            throw NetworkableError.unacceptableStatusCode(response, data)
        }
    }
    
    // MARK: Middleware
    
    public func prepare(request: URLRequest) throws -> URLRequest {
        request
    }
    
    public func willSend(request: URLRequest) {}
    
    public func didReceive(response: URLResponse, data: Data) throws {
        try validate(response: response, data: data)
    }
    
    public func didReceive(error: Error, of request: URLRequest) {}
}

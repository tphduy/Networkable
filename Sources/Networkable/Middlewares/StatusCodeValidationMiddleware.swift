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
    public let acceptableStatusCodes: ResponseStatusCodes
    
    // MARK: Init
    
    /// Initiate a middleware determines whether a response is valid by verifying its status code.
    /// - Parameter acceptableStatusCodes: A range of HTTP response status codes that specifies a response is valid.
    public init(acceptableStatusCodes: ResponseStatusCodes = .success) {
        self.acceptableStatusCodes = acceptableStatusCodes
    }
    
    // MARK: Middleware
    
    public func prepare(request: URLRequest) throws -> URLRequest { request }
    
    public func willSend(request: URLRequest) {}
    
    public func didReceive(response: URLResponse, data: Data) throws {
        try validate(response: response)
    }
    
    // MARK: Main
    
    /// Validate a response whether it is an HTTP response and its status code is acceptable.
    /// - Parameter response: An object abstracts informations about a response. It's must be an instance of `HTTPURLResponse`.
    /// - Throws: An unexpected response error if the response is not HTTP response, or an unacceptable code error if the response's status code is not acceptable.
    func validate(response: URLResponse) throws {
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkableError.unexpectedResponse(response)
        }
        
        guard acceptableStatusCodes.contains(code) else {
            throw NetworkableError.unacceptableStatusCode(code, response)
        }
    }
}

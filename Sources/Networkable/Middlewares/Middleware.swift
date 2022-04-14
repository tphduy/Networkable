//
//  Middleware.swift
//  Networkable
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

/// An object performs side effects whenever a request is sent or a response is received.
public protocol Middleware {
    /// Prepare a request before sending.
    /// - Parameter request: An object abstract information about a request.
    func prepare(request: URLRequest) throws -> URLRequest
    
    /// Notify a prepared request is about to be sent.
    /// - Parameter request: An object abstract information about the request.
    func willSend(request: URLRequest)
    
    /// Receive a response with data
    /// - Parameters:
    ///   - response: An object abstract information about a response.
    ///   - data: The data returned by the server.
    func didReceive(response: URLResponse, data: Data) throws
}

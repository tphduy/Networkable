//
//  Middleware.swift
//  Networkable
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

/// An object performs side effects whenever a request is sent or a response is received.
public protocol Middleware {
    /// Prepares a request before sending.
    /// - Parameter request: An URL load request that is independent of protocol or URL scheme.
    func prepare(request: URLRequest) throws -> URLRequest
    
    /// Notifies a prepared request is about to be sent.
    /// - Parameter request: An URL load request that is independent of protocol or URL scheme.
    func willSend(request: URLRequest)
    
    /// Notifies a response and data was received.
    /// - Parameters:
    ///   - response: The metadata associated with the response to a URL load request, independent of protocol and URL scheme.
    ///   - data: The contents that is specified by a request.
    func didReceive(response: URLResponse, data: Data) throws
    
    /// Notifies a request did encounter an error.
    /// - Parameters:
    ///   - error: An error that interrupted the request loading.
    ///   - request: An URL load request that is independent of protocol or URL scheme.
    func didReceive(error: Error, of request: URLRequest)
}

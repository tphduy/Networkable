//
//  Middleware.swift
//  Networkable
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

/// An object perform side effects wherever a request is sent or received.
public protocol Middleware {
    
    /// Prepare a request before sending.
    /// - Parameter request: the request to prepare.
    func prepare(request: URLRequest) throws -> URLRequest
    
    /// Notify a prepared request is about to be sent.
    /// - Parameter request: the request will be sent.
    func willSend(request: URLRequest)
    
    /// Receive a response with data
    /// - Parameters:
    ///   - response: an object that provides response metadata.
    ///   - data: the data returned by the server.
    func didReceive(response: URLResponse, data: Data) throws
}

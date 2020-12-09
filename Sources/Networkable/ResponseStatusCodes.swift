//
//  ResponseStatusCodes.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

/// HTTP response status code indicate whether a specific HTTP request has been successfully completed.
public typealias ResponseStatusCode = Int

/// HTTP response status codes indicate whether a specific HTTP request has been successfully completed.
public typealias ResponseStatusCodes = ClosedRange<ResponseStatusCode>

extension ResponseStatusCodes {
    
    /// The request has succeeded.
    public static var success = 200 ... 299
    
    /// The URL of the requested resource has been changed
    public static var redirection = 300 ... 399
    
    /// The request has failed.
    public static var error = 400 ... 499
    
    /// The server has encountered a situation it doesn't know how to handle.
    public static var serverError = 500 ... 511
}

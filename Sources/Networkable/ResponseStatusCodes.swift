//
//  ResponseStatusCodes.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

/// A range of HTTP response status codes indicates whether a specific HTTP request has been successfully completed.
public typealias ResponseStatusCodes = ClosedRange<Int>

extension ResponseStatusCodes {
    /// The request was success.
    public static var success = 200 ... 299
    
    /// The URL of the requested resource was changed.
    public static var redirection = 300 ... 399
    
    /// The request was failed.
    public static var error = 400 ... 499
    
    /// The server has encountered a situation it doesn't know how to handle.
    public static var serverError = 500 ... 511
}

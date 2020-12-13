//
//  LoggingMiddleware.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation
#if canImport(os)
import os
#endif

/// A middleware logs network activities to a logging system.
public struct LoggingMiddleware: Middleware {
    
    // MARK: - Dependencies
    
    /// The log level to assign to the message
    public var type: OSLogType
    
    /// The custom log object categorizes the log messages.
    public var log: OSLog

    // MARK: - Init
    
    /// Creates a middleware logs network activities to a logging system.
    /// - Parameters:
    ///   - type: The log level to assign to the message. Default is `.default`.
    ///   - log: The custom log object categorizes the log message. Default is `.default`.
    public init(
        type: OSLogType = .default,
        log: OSLog = .default) {
        self.type = type
        self.log = log
    }
    
    // MARK: - Middleware
    
    public func prepare(request: URLRequest) throws -> URLRequest {
        return request
    }

    public func willSend(request: URLRequest) {
        let message = log(request: request)
        log(message: message)
    }

    public func didReceive(response: URLResponse, data: Data) throws {
        let message = log(response: response, data: data)
        log(message: message)
    }

    // MARK: - Main
    
    /// Create a string describing a request.
    /// - Parameter request: A request to describe.
    /// - Returns: A string describes the request.
    public func log(request: URLRequest) -> String {
        return request.logging()
    }
    
    /// Create a string describing a response and its associated data that is loaded by a request before.
    /// - Parameters:
    ///   - response: A response to describe.
    ///   - data: A loaded data.
    /// - Returns: A string describing a response and its associated data.
    public func log(response: URLResponse, data: Data) -> String {
        var message = response.logging()
        
        guard
            !data.isEmpty,
            let data = String(data: data, encoding: .utf8)
        else { return message }
        
        message += "\n" + data
        
        return message
    }
    
    /// Log a message to logging system.
    /// - Parameter message: A message to log.
    public func log(message: String) {
        if #available(iOS 10, macOS 10.12, macCatalyst 13.0, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", log: log, type: type, message)
        } else {
            debugPrint(message)
        }
    }
}

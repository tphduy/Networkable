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
    // MARK: Dependencies
    
    /// The log level to assign to the message.
    public var type: OSLogType
    
    /// The custom log object categorizes the log messages.
    public var log: OSLog

    // MARK: Init
    
    /// Initiate a middleware logs network activities to a logging system.
    /// - Parameters:
    ///   - type: The log level to assign to the message. The default value is `.default`.
    ///   - log: The custom log object categorizes the log message. The default value is `.default`.
    public init(
        type: OSLogType = .default,
        log: OSLog = .default
    ) {
        self.type = type
        self.log = log
    }
    
    // MARK: Middleware
    
    public func prepare(request: URLRequest) throws -> URLRequest { request }

    public func willSend(request: URLRequest) {
        let message = log(request: request)
        log(message: message)
    }

    public func didReceive(response: URLResponse, data: Data) throws {
        let message = log(response: response, data: data)
        log(message: message)
    }

    // MARK: Main
    
    /// Return a `String` representing a request.
    /// - Parameter request: An object abstracts information about the request.
    /// - Returns:  a `String` representing a request.
    func log(request: URLRequest) -> String {
        request.logging()
    }
    
    /// Return a `String` representing a response with the data returned by the server.
    /// - Parameters:
    ///   - response: An object abstracts information about a response.
    ///   - data: The data returned by the server.
    /// - Returns: A `String` representing a response with the data returned by the server.
    func log(response: URLResponse, data: Data) -> String {
        [response.logging(), String(data: data, encoding: .utf8)]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }
    
    /// Log a message to logging system.
    /// - Parameter message: A message to log.
    func log(message: String) {
        if #available(iOS 10, macOS 10.12, macCatalyst 13.0, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", log: log, type: type, message)
        } else {
            debugPrint(message)
        }
    }
}

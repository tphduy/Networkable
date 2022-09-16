//
//  LoggingMiddleware.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation
import os

/// A middleware that logs network activities to a logging system.
public struct LoggingMiddleware: Middleware {
    // MARK: Dependencies
    
    /// The log level to assign to the message.
    public var type: OSLogType
    
    /// The custom log object categorizes the log messages.
    public var log: OSLog

    // MARK: Init
    
    /// Initiate a middleware that logs network activities to a logging system.
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

    // MARK: Utilities
    
    /// Returns a text that represents an URL load request .
    /// - Parameter request: A URL load request that is independent of protocol or URL scheme.
    /// - Returns: An empty text if the URL of request is invalid, otherwise, a non-empty text.
    func makeDescription(request: URLRequest) -> String {
        guard let url = request.url else { return "" }
        let title = "🚀 Request: \(url.absoluteString)"
        let method = request.httpMethod.map { "-X \($0)" }
        let headers = request.allHTTPHeaderFields?
            .map { "-H \"\($0)\": \"\($1)\"" }
            .sorted() ?? []
        let body = request.httpBody
            .map { String(data: $0, encoding: .utf8) }?
            .map { "-d \"\($0)\"" }
        let result = ([title, method] + headers + [body])
            .compactMap { $0 }
            .joined(separator: "\n    ")
        return result
    }
    
    /// Returns a text that represents an URL load request .
    /// - Parameters:
    ///   - request: A URL load request that is independent of protocol or URL scheme.
    ///   - error: An error that interrupted the request loading.
    /// - Returns: An empty text if the URL of request is invalid, otherwise, a non-empty text.
    func makeDescription(request: URLRequest, error: Error) -> String {
        guard let url = request.url else { return "" }
        let result = "📌 Request: \(url.absoluteString) did encounter an error: \(error.localizedDescription)"
        return result
    }
     
    /// Returns a text t.hat represents the metadata associated with the response to a URL load reques
    /// - Parameter response: The metadata associated with the response to a URL load request, independent of protocol and URL scheme.
    /// - Returns: An empty text if the URL of response is invalid, otherwise, a non-empty text.
    func makeDescription(response: URLResponse) -> String {
        guard let url = response.url else { return "" }
        let title = "📩 Response: \(url.absoluteString)"
        guard let response = response as? HTTPURLResponse else { return title }
        let statusCode = "-H \(response.statusCode)"
        let headers = response.allHeaderFields
            .map { "-H \"\($0): \($1)\"" }
            .sorted()
        let result = ([title, statusCode] + headers)
            .joined(separator: "\n    ")
        return result
    }
    
    /// Return a `String` representing a response with the data returned by the server.
    /// - Parameters:
    ///   - response: An object abstracts information about a response.
    ///   - data: The data returned by the server.
    /// - Returns: A `String` representing a response with the data returned by the server.
    func makeDescription(response: URLResponse, withData data: Data) -> String {
        let response = makeDescription(response: response)
        let data = String(data: data, encoding: .utf8)
        let result = [response, data]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        return result
    }
    
    // MARK: Side Effects
    
    /// Log a message to logging system.
    /// - Parameter message: A message to log.
    func log(message: String) {
        if #available(iOS 10, macOS 10.12, macCatalyst 13.0, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", log: log, type: type, message)
        } else {
            debugPrint(message)
        }
    }
    
    // MARK: Middleware
    
    public func prepare(request: URLRequest) throws -> URLRequest {
        request
    }

    public func willSend(request: URLRequest) {
        let message = makeDescription(request: request)
        log(message: message)
    }

    public func didReceive(response: URLResponse, data: Data) throws {
        let message = makeDescription(response: response, withData: data)
        log(message: message)
    }
    
    public func didReceive(error: Error, of request: URLRequest) {
        let message = makeDescription(request: request, error: error)
        log(message: message)
    }
}

//
//  LoggingMiddleware.swift
//  Networking
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation
import os.log

@available(OSX 10.14, *)
public protocol LoggingMiddleware: Middleware {
    var log: OSLog { get }
    func log(request: URLRequest)
    func log(response: URLResponse)
    func log(data: Data)
}

@available(OSX 10.14, *)
public struct DefaultLoggingMiddleware: LoggingMiddleware {
    public let type: OSLogType
    public let log: OSLog

    public init(type: OSLogType = .info, log: OSLog = .default) {
        self.type = type
        self.log = log
    }

    public func log(request: URLRequest) {
        let logging = request.logging()
        guard !logging.isEmpty else {
            return
        }
        os_log(type, log: log, "%@", logging)
    }

    public func log(response: URLResponse) {
        let logging = response.logging()
        guard !logging.isEmpty else {
            return
        }
        os_log(type, log: log, "%@", logging)
    }

    public func log(data: Data) {
        guard let logging = String(data: data, encoding: .utf8) else {
            return
        }
        os_log(type, log: log, "%@", logging)
    }

    public func willSend(request: URLRequest) {
        log(request: request)
    }

    public func didReceive(response: URLResponse) throws {
        log(response: response)
    }

    public func didReceive(data: Data) throws {
        log(data: data)
    }
}

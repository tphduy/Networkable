//
//  LoggingMiddleware.swift
//  Networking
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation
import os.log

public protocol LoggingMiddleware: Middleware {
    func log(request: URLRequest)
    func log(response: URLResponse)
    func log(data: Data)
}

public struct DefaultLoggingMiddleware: LoggingMiddleware {
    public let type: OSLogType
    public let log: OSLog

    @available(OSX 10.12, *)
    public init(
        type: OSLogType = .default,
        log: OSLog = .default) {
        self.type = type
        self.log = log
    }

    public func log(request: URLRequest) {
        let logging = request.logging()
        guard !logging.isEmpty else {
            return
        }
        
        if #available(iOS 12.0, OSX 10.14, *) {
            os_log(type, log: log, "%@", logging)
        } else {
            debugPrint(logging)
        }
    }

    public func log(response: URLResponse) {
        let logging = response.logging()
        guard !logging.isEmpty else {
            return
        }
        
        if #available(iOS 12.0, OSX 10.14, *) {
            os_log(type, log: log, "%@", logging)
        } else {
            debugPrint(logging)
        }
    }

    public func log(data: Data) {
        guard let logging = String(data: data, encoding: .utf8) else {
            return
        }
        
        if #available(iOS 12.0, OSX 10.14, *) {
            os_log(type, log: log, "%@", logging)
        } else {
            debugPrint(logging)
        }
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

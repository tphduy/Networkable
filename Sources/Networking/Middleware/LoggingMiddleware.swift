//
//  LoggingMiddleware.swift
//  Networking
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation
import os.log

public protocol LoggingMiddleware: Middleware {
    func log(request: URLRequest) -> String
    func log(response: URLResponse, data: Data) -> String
}

extension LoggingMiddleware {
    public func log(request: URLRequest) -> String {
        return request.logging()
    }

    public func log(response: URLResponse, data: Data) -> String {
        var logging = response.logging()
        if let data = String(data: data, encoding: .utf8), !data.isEmpty {
            logging += "\n" + data
        }
        return logging
    }
}

public struct DefaultLoggingMiddleware: LoggingMiddleware {
    public let type: OSLogType
    public let log: OSLog

    @available(OSX 10.12, *)
    public init(type: OSLogType = .default, log: OSLog = .default) {
        self.type = type
        self.log = log
    }
    
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

    // MARK: - Private

    private func log(message: String) {
        if #available(iOS 12.0, OSX 10.14, *) {
            os_log(type, log: log, "%@", message)
        } else {
            debugPrint(message)
        }
    }
}

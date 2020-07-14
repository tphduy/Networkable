//
//  Middleware.swift
//  Networking
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

public protocol Middleware {
    func prepare(request: URLRequest) throws -> URLRequest
    func willSend(request: URLRequest)
    func didReceive(response: URLResponse) throws
    func didReceive(data: Data) throws
}

extension Middleware {
    public func prepare(request: URLRequest) throws -> URLRequest {
        return request
    }

    public func willSend(request: URLRequest) {}

    public func didReceive(response: URLResponse) throws {}

    public func didReceive(data: Data) throws {}
}

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
    func didReceive(response: URLResponse, data: Data) throws
}

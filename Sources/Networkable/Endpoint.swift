//
//  Endpoint.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

public protocol Endpoint {
    var headers: [String: String]? { get }
    var path: String { get }
    var method: Method { get }
    func body() throws -> Data?
}

extension Endpoint {
    var headers: [String: String]? { nil }
    func body() throws -> Data? { nil }
}

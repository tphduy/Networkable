//
//  Endpoint.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// The object that re-presents the request components.
public protocol Endpoint {
    
    /// A dictionary containing all of the header fields for the request.
    var headers: [String: String]? { get }
    
    /// The path component of the URL for  the request.
    var path: String { get }
    
    /// The  method for the request.
    var method: Method { get }
    
    /// The data sent as the message body of the request.
    func body() throws -> Data?
}

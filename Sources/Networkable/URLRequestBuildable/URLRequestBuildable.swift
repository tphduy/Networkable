//
//  URLRequestBuildable.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// A type can build an URL load request that is independent of protocol or URL scheme.
public protocol URLRequestBuildable {
    /// Builds an URL load request that is independent of protocol or URL scheme.
    /// - Parameter request: An object abstracts an HTTP request.
    /// - Returns: An URL load request that is independent of protocol or URL scheme.
    func build(request: Request) throws -> URLRequest
}

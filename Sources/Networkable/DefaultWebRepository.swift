//
//  DefaultWebRepository.swift
//  
//
//  Created by Duy Tran on 15/04/2022.
//

import Foundation

/// An ad-hoc network layer that is built on URLSession to perform an HTTP request.
public struct DefaultWebRepository: WebRepository {
    
    /// The shared web repository instance.
    static public let shared = Self.init()
    
    // MARK: Dependencies
    
    public var requestBuilder: URLRequestBuildable
    
    public var middlewares: [Middleware]
    
    public var session: URLSession
    
    // MARK: Init
    
    /// Initiate an object that performs an HTTP request.
    /// - Parameters:
    ///   - requestBuilder: An object that constructs an HTTP request.
    ///   - middlewares: A list of middlewares that will perform side effects whenever a request is sent or a response is received.
    ///   - session: An object that coordinates a group of related, network data-transfer tasks.
    public init(
        requestBuilder: URLRequestBuildable = URLRequestBuilder(),
        middlewares: [Middleware] = [LoggingMiddleware()],
        session: URLSession = .shared
    ) {
        self.requestBuilder = requestBuilder
        self.middlewares = middlewares
        self.session = session
    }
}

//
//  DefaultWebRepository.swift
//  
//
//  Created by Duy Tran on 15/04/2022.
//

import Foundation

public struct DefaultWebRepository: WebRepository {
    
    static let shared = DefaultWebRepository()
    
    // MARK: - Dependencies
    
    public var requestBuilder: URLRequestBuildable
    public var middlewares: [Middleware]
    public var session: URLSession
    
    // MARK: - Init
    
    public init(
        requestFactory: URLRequestBuildable = URLRequestBuilder(),
        middlewares: [Middleware] = [LoggingMiddleware()],
        session: URLSession = .shared) {
        self.requestBuilder = requestFactory
        self.middlewares = middlewares
        self.session = session
    }
}

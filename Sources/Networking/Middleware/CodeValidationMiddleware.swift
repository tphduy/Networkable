//
//  CodeValidationMiddleware.swift
//  Networking
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

protocol CodeValidationMiddleware: Middleware {
    var acceptableCodes: HTTPCodes { get }
    func invalidate(response: URLResponse) throws
}

extension CodeValidationMiddleware {
    public func invalidate(response: URLResponse) throws {
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkingError.unexpectedResponse(response)
        }
        
        guard acceptableCodes.contains(code) else {
            throw NetworkingError.unacceptableCode(code, response)
        }
    }
}

public struct DefaultCodeValidationMiddleware: CodeValidationMiddleware {
    public let acceptableCodes: HTTPCodes
    
    public init(acceptableCodes: HTTPCodes = .success) {
        self.acceptableCodes = acceptableCodes
    }
    
    public func didReceive(response: URLResponse) throws {
        try invalidate(response: response)
    }
}

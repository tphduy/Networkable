//
//  CodeValidationMiddleware.swift
//  Networkable
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation

protocol CodeValidationMiddleware: Middleware {
    var acceptableCodes: ResponseStatusCodes { get }
    func invalidate(response: URLResponse) throws
}

extension CodeValidationMiddleware {
    public func invalidate(response: URLResponse) throws {
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkableError.unexpectedResponse(response)
        }
        
        guard acceptableCodes.contains(code) else {
            throw NetworkableError.unacceptableCode(code, response)
        }
    }
}

public struct DefaultCodeValidationMiddleware: CodeValidationMiddleware {
    public let acceptableCodes: ResponseStatusCodes
    
    public init(acceptableCodes: ResponseStatusCodes = .success) {
        self.acceptableCodes = acceptableCodes
    }
    
    public func prepare(request: URLRequest) throws -> URLRequest {
        return request
    }
    
    public func willSend(request: URLRequest) {}
    
    public func didReceive(response: URLResponse, data: Data) throws {
        try invalidate(response: response)
    }
}

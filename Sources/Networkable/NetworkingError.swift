//
//  NetworkableError.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// The possible errors maybe  throw during sending a request and processing a response.
public enum NetworkableError: Error, Equatable {
    /// A response is well-received but without any data.
    case empty
    
    /// The text re-presents an URL of a request that is invalid.
    case invalidURL(String, relativeURL: URL?)
    
    /// An unexpected response is received.
    case unexpectedResponse(URLResponse, Data)
    
    /// A response with an unacceptable status code is received.
    case unacceptableStatusCode(HTTPURLResponse, Data)
    
    // MARK: Utilities
    
    /// The data was returned along with the response.
    public var data: Data? {
        switch self {
        case let .unexpectedResponse(_, data), let .unacceptableStatusCode(_, data):
            return data
        default:
            return nil
        }
    }
}

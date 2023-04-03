//
//  NetworkableError.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// A type that defines the possible errors may be thrown during sending a request and processing a response.
public enum NetworkableError: Error, Equatable {
    /// The text represents an URL of an invalid request.
    case invalidURL(String, relativeURL: URL?)
    
    /// An unexpected response was received.
    case unexpectedResponse(URLResponse, Data)
    
    /// A response with an unacceptable status code was received.
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

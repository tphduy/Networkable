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
    
    /// The string re-presenting a request's URL is invalid
    case invalidURL(String)
    
    /// An unexpected response  is received.
    case unexpectedResponse(URLResponse)
    
    /// A response has unacceptable status code is received.
    case unacceptableCode(ResponseStatusCode, URLResponse)
}

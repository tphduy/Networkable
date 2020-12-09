//
//  NetworkableError.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

public enum NetworkableError: Error, Equatable {
    case empty
    case invalidURL(String)
    case unexpectedResponse(URLResponse)
    case unacceptableCode(ResponseStatusCode, URLResponse)
}

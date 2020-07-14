//
//  NetworkingError.swift
//  Networking
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

public enum NetworkingError: Error, Equatable {
    case invalidURL(String)
    case unexpectedResponse(URLResponse)
    case unacceptableCode(HTTPCode, URLResponse)
}

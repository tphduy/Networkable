//
//  SpyURLRequestFactory.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation
@testable import Networking

final class SpyURLRequestFactory: URLRequestFactory {
    var invokedRawURLGetter = false
    var invokedRawURLGetterCount = 0
    var stubbedRawURL: String! = ""

    var host: String {
        invokedRawURLGetter = true
        invokedRawURLGetterCount += 1
        return stubbedRawURL
    }

    var invokedMake = false
    var invokedMakeCount = 0
    var invokedMakeParameters: (endpoint: Endpoint, Void)?
    var invokedMakeParametersList = [(endpoint: Endpoint, Void)]()
    var stubbedMakeError: Error?
    var stubbedMakeResult: URLRequest!

    func make(endpoint: Endpoint) throws -> URLRequest {
        invokedMake = true
        invokedMakeCount += 1
        invokedMakeParameters = (endpoint, ())
        invokedMakeParametersList.append((endpoint, ()))
        if let error = stubbedMakeError {
            throw error
        }
        return stubbedMakeResult
    }
}

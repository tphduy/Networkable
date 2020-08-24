//
//  SpyEndpoint.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation
@testable import Networking

final class SpyEndpoint: Endpoint {
    var invokedHeadersGetter = false
    var invokedHeadersGetterCount = 0
    var stubbedHeaders: [String: String]!

    var headers: [String: String]? {
        invokedHeadersGetter = true
        invokedHeadersGetterCount += 1
        return stubbedHeaders
    }

    var invokedPathGetter = false
    var invokedPathGetterCount = 0
    var stubbedPath: String! = ""

    var path: String {
        invokedPathGetter = true
        invokedPathGetterCount += 1
        return stubbedPath
    }

    var invokedMethodGetter = false
    var invokedMethodGetterCount = 0
    var stubbedMethod: Networking.Method!

    var method: Networking.Method {
        invokedMethodGetter = true
        invokedMethodGetterCount += 1
        return stubbedMethod
    }

    var invokedBody = false
    var invokedBodyCount = 0
    var stubbedBodyError: Error?
    var stubbedBodyResult: Data!

    func body() throws -> Data? {
        invokedBody = true
        invokedBodyCount += 1
        if let error = stubbedBodyError {
            throw error
        }
        return stubbedBodyResult
    }
}

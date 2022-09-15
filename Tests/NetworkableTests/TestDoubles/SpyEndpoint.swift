//
//  SpyEndpoint.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation
@testable import Networkable

final class SpyEndpoint: Request {

    var invokedHeadersGetter = false
    var invokedHeadersGetterCount = 0
    var stubbedHeaders: [String: String]!

    var headers: [String: String]? {
        invokedHeadersGetter = true
        invokedHeadersGetterCount += 1
        return stubbedHeaders
    }

    var invokedUrlGetter = false
    var invokedUrlGetterCount = 0
    var stubbedUrl: String! = ""

    var url: String {
        invokedUrlGetter = true
        invokedUrlGetterCount += 1
        return stubbedUrl
    }

    var invokedMethodGetter = false
    var invokedMethodGetterCount = 0
    var stubbedMethod: Networkable.Method!

    var method: Networkable.Method {
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

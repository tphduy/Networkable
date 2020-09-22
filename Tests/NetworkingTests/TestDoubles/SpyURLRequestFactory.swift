//
//  SpyURLRequestFactory.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation
@testable import Networking

final class SpyURLRequestFactory: URLRequestFactory {

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

    var invokedMakeEndpoint = false
    var invokedMakeEndpointCount = 0
    var invokedMakeEndpointParameters: (endpoint: Endpoint, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval)?
    var invokedMakeEndpointParametersList = [(endpoint: Endpoint, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval)]()
    var stubbedMakeEndpointError: Error?
    var stubbedMakeEndpointResult: URLRequest!

    func make(
        endpoint: Endpoint,
        cachePolicy: URLRequest.CachePolicy,
        timeoutInterval: TimeInterval) throws -> URLRequest {
        invokedMakeEndpoint = true
        invokedMakeEndpointCount += 1
        invokedMakeEndpointParameters = (endpoint, cachePolicy, timeoutInterval)
        invokedMakeEndpointParametersList.append((endpoint, cachePolicy, timeoutInterval))
        if let error = stubbedMakeEndpointError {
            throw error
        }
        return stubbedMakeEndpointResult
    }
}

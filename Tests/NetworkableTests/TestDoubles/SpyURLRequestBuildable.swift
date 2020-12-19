//
//  SpyURLRequestBuildable.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation
@testable import Networkable

final class SpyURLRequestBuildable: URLRequestBuildable {

    var invokedBaseURLSetter = false
    var invokedBaseURLSetterCount = 0
    var invokedBaseURL: URL?
    var invokedBaseURLList = [URL?]()
    var invokedBaseURLGetter = false
    var invokedBaseURLGetterCount = 0
    var stubbedBaseURL: URL!

    var baseURL: URL? {
        set {
            invokedBaseURLSetter = true
            invokedBaseURLSetterCount += 1
            invokedBaseURL = newValue
            invokedBaseURLList.append(newValue)
        }
        get {
            invokedBaseURLGetter = true
            invokedBaseURLGetterCount += 1
            return stubbedBaseURL
        }
    }

    var invokedCachePolicySetter = false
    var invokedCachePolicySetterCount = 0
    var invokedCachePolicy: URLRequest.CachePolicy?
    var invokedCachePolicyList = [URLRequest.CachePolicy]()
    var invokedCachePolicyGetter = false
    var invokedCachePolicyGetterCount = 0
    var stubbedCachePolicy: URLRequest.CachePolicy!

    var cachePolicy: URLRequest.CachePolicy {
        set {
            invokedCachePolicySetter = true
            invokedCachePolicySetterCount += 1
            invokedCachePolicy = newValue
            invokedCachePolicyList.append(newValue)
        }
        get {
            invokedCachePolicyGetter = true
            invokedCachePolicyGetterCount += 1
            return stubbedCachePolicy
        }
    }

    var invokedTimeoutIntervalSetter = false
    var invokedTimeoutIntervalSetterCount = 0
    var invokedTimeoutInterval: TimeInterval?
    var invokedTimeoutIntervalList = [TimeInterval]()
    var invokedTimeoutIntervalGetter = false
    var invokedTimeoutIntervalGetterCount = 0
    var stubbedTimeoutInterval: TimeInterval!

    var timeoutInterval: TimeInterval {
        set {
            invokedTimeoutIntervalSetter = true
            invokedTimeoutIntervalSetterCount += 1
            invokedTimeoutInterval = newValue
            invokedTimeoutIntervalList.append(newValue)
        }
        get {
            invokedTimeoutIntervalGetter = true
            invokedTimeoutIntervalGetterCount += 1
            return stubbedTimeoutInterval
        }
    }

    var invokedMake = false
    var invokedMakeCount = 0
    var invokedMakeParameters: (endpoint: Endpoint, Void)?
    var invokedMakeParametersList = [(endpoint: Endpoint, Void)]()
    var stubbedMakeError: Error?
    var stubbedMakeResult: URLRequest!

    func build(endpoint: Endpoint) throws -> URLRequest {
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

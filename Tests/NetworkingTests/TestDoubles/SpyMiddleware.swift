//
//  SpyMiddleware.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation
@testable import Networking

final class SpyMiddleware: Middleware {
    var invokedPrepare = false
    var invokedPrepareCount = 0
    var invokedPrepareParameters: (request: URLRequest, Void)?
    var invokedPrepareParametersList = [(request: URLRequest, Void)]()
    var stubbedPrepareError: Error?
    var stubbedPrepareResult: URLRequest!

    func prepare(request: URLRequest) throws -> URLRequest {
        invokedPrepare = true
        invokedPrepareCount += 1
        invokedPrepareParameters = (request, ())
        invokedPrepareParametersList.append((request, ()))
        if let error = stubbedPrepareError {
            throw error
        }
        return stubbedPrepareResult
    }

    var invokedWillSend = false
    var invokedWillSendCount = 0
    var invokedWillSendParameters: (request: URLRequest, Void)?
    var invokedWillSendParametersList = [(request: URLRequest, Void)]()

    func willSend(request: URLRequest) {
        invokedWillSend = true
        invokedWillSendCount += 1
        invokedWillSendParameters = (request, ())
        invokedWillSendParametersList.append((request, ()))
    }

    var invokedDidReceiveResponse = false
    var invokedDidReceiveResponseCount = 0
    var invokedDidReceiveResponseParameters: (response: URLResponse, Void)?
    var invokedDidReceiveResponseParametersList = [(response: URLResponse, Void)]()
    var stubbedDidReceiveResponseError: Error?

    func didReceive(response: URLResponse) throws {
        invokedDidReceiveResponse = true
        invokedDidReceiveResponseCount += 1
        invokedDidReceiveResponseParameters = (response, ())
        invokedDidReceiveResponseParametersList.append((response, ()))
        if let error = stubbedDidReceiveResponseError {
            throw error
        }
    }

    var invokedDidReceiveData = false
    var invokedDidReceiveDataCount = 0
    var invokedDidReceiveDataParameters: (data: Data, Void)?
    var invokedDidReceiveDataParametersList = [(data: Data, Void)]()
    var stubbedDidReceiveDataError: Error?

    func didReceive(data: Data) throws {
        invokedDidReceiveData = true
        invokedDidReceiveDataCount += 1
        invokedDidReceiveDataParameters = (data, ())
        invokedDidReceiveDataParametersList.append((data, ()))
        if let error = stubbedDidReceiveDataError {
            throw error
        }
    }
}

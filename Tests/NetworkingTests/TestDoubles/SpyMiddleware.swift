//
//  SpyMiddleware.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation
@testable import Networking

final class SpyMiddleware: Middleware, Equatable {
    
    static func == (lhs: SpyMiddleware, rhs: SpyMiddleware) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    let uuid = UUID()

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

    var invokedDidReceive = false
    var invokedDidReceiveCount = 0
    var invokedDidReceiveParameters: (response: URLResponse, data: Data)?
    var invokedDidReceiveParametersList = [(response: URLResponse, data: Data)]()
    var stubbedDidReceiveError: Error?

    func didReceive(response: URLResponse, data: Data) throws {
        invokedDidReceive = true
        invokedDidReceiveCount += 1
        invokedDidReceiveParameters = (response, data)
        invokedDidReceiveParametersList.append((response, data))
        if let error = stubbedDidReceiveError {
            throw error
        }
    }
}

//
//  StubbedURLProtocol.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

final class StubbedURLProtocol: URLProtocol {
    static var stubbedData = [URLRequest: Data]()
    static var stubbedResponse = [URLRequest: URLResponse]()
    static var stubbedResponseError = [URLRequest: Error]()

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let response = Self.stubbedResponse[request] {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = Self.stubbedData[request] {
            client?.urlProtocol(self, didLoad: data)
        }

        if let error = Self.stubbedResponseError[self.request] {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

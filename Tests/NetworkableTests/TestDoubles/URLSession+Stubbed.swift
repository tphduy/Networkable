//
//  URLSession+Stubbed.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

extension URLSession {
    static var stubbed: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubbedURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    func set(stubbedResponse response: URLResponse?, for request: URLRequest) {
        StubbedURLProtocol.stubbedResponse[request] = response
    }

    func set(stubbedResponseError error: Error?, for request: URLRequest) {
        StubbedURLProtocol.stubbedResponseError[request] = error
    }

    func set(stubbedData data: Data?, for request: URLRequest) {
        StubbedURLProtocol.stubbedData[request] = data
    }

    func tearDown() {
        StubbedURLProtocol.stubbedResponse.removeAll()
        StubbedURLProtocol.stubbedResponseError.removeAll()
        StubbedURLProtocol.stubbedData.removeAll()
    }
}

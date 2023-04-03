//
//  LoggingMiddlewareTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest
import os
@testable import Networkable

final class LoggingMiddlewareTests: XCTestCase {
    // MARK: Misc
    
    private var request: URLRequest!
    private var response: URLResponse!
    private var type: OSLogType!
    private var log: OSLog!
    private var sut: LoggingMiddleware!
    
    // MARK: Life Cycle
    
    override func setUpWithError() throws {
        request = makeRequest()
        response = makeResponse(statusCode: 200)
        type = .debug
        log = .disabled
        sut = LoggingMiddleware(type: type, log: log)
    }
    
    override func tearDownWithError() throws {
        request = nil
        response = nil
        type = nil
        log = nil
        sut = nil
    }
    
    // MARK: Test Cases - init(type:log)
    
    func test_init() throws {
        XCTAssertEqual(type, sut.type)
        XCTAssertEqual(log, sut.log)
    }
    
    // MARK: Test Cases - makeDescription(request:)
    
    func test_makeDescriptionOfRequest() throws {
        let result = sut.makeDescription(request: request)
        let expected = """
        🚀 Request: https://foo.bar/foo/bar?foo=bar?fizz=buzz
            -X POST
            -H "bar": "foo"
            -H "buzz": "fizz"
            -d "{"foo":"bar"}"
        """
        
        XCTAssertEqual(result, expected)
    }
    
    // MARK: Test Cases - makeDescription(request:error)
    
    func test_makeDescriptionOfRequestAndError() throws {
        let error = DummyError()
        let result = sut.makeDescription(request: request, error: error)
        let expected = """
        📌 Request: https://foo.bar/foo/bar?foo=bar?fizz=buzz did encounter an error: \(error.localizedDescription)
        """
        
        XCTAssertEqual(result, expected)
    }
    
    // MARK: Test Cases - makeDescription(response:)
    
    func test_makeDescriptionOfResponse() throws {
        let result = sut.makeDescription(response: response)
        let expected = """
        📩 Response: https://foo.bar/foo/bar?foo=bar?fizz=buzz
            -H 200
            -H "fizz: buzz"
            -H "foo: bar"
        """
        
        XCTAssertEqual(result, expected)
    }
    
    // MARK: Test Cases -  makeDescription(response:withData)
    
    func test_makeDescriptionOfResponseWithData() throws {
        let data = makeBody().data(using: .utf8)!
        let result = sut.makeDescription(response: response, data: data)
        let expected = """
        📩 Response: https://foo.bar/foo/bar?foo=bar?fizz=buzz
            -H 200
            -H "fizz: buzz"
            -H "foo: bar"
        {"foo":"bar"}
        """
        
        XCTAssertEqual(result, expected)
    }
    
    // MARK: Test Cases - prepare(request:)
    
    func test_prepareRequest() throws {
        XCTAssertEqual(try! sut.prepare(request: request), request)
    }
    
    // MARK: Test Cases - willSend(request:)
    
    func willSend(request: URLRequest) {
        sut.willSend(request: request)
    }
    
    // MARK: Test Cases - didReceive(response:data)

    func test_didReceiveResponseAndData() throws {
        try sut.didReceive(response: makeResponse(statusCode: 200), data: Data())
    }
    
    // MARK: Test Cases - didReceive(error:of:)
    
    func didReceive(error: Error, of request: URLRequest) {
        sut.didReceive(error: DummyError(), of: request)
    }
}

extension LoggingMiddlewareTests {
    // MARK: Utilities
    
    private func makeURL() -> URL {
        URL(string: "https://foo.bar/foo/bar?foo=bar?fizz=buzz")!
    }
    
    private func makeBody() -> String {
        """
        {"foo":"bar"}
        """
    }
    
    private func makeRequest() -> URLRequest {
        var result = URLRequest(url: makeURL())
        result.httpMethod = "POST"
        result.addValue("foo", forHTTPHeaderField: "bar")
        result.addValue("fizz", forHTTPHeaderField: "buzz")
        result.httpBody = makeBody().data(using: .utf8)
        return result
    }
    
    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: makeURL(),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: [
                "foo": "bar",
                "fizz": "buzz"
            ])!
    }
}

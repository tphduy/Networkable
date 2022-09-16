//
//  DefaultStatusCodeValidationMiddlewareTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/14/20.
//

import XCTest
@testable import Networkable

final class StatusCodeValidationMiddlewareTests: XCTestCase {
    // MARK: Misc
    
    private var request: URLRequest!
    private var acceptableStatusCodes: ResponseStatusCodes!
    private var sut: StatusCodeValidationMiddleware!
    
    // MARK: Life Cycle

    override func setUpWithError() throws {
        request = makeRequest()
        acceptableStatusCodes = .success
        sut = StatusCodeValidationMiddleware(acceptableStatusCodes: acceptableStatusCodes)
    }

    override func tearDownWithError() throws {
        request = nil
        acceptableStatusCodes = nil
        sut = nil
    }
    
    // MARK: Test Cases - init(acceptableStatusCodes:)
    
    func test_init() throws {
        XCTAssertEqual(sut.acceptableStatusCodes, acceptableStatusCodes)
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

    func test_didReceiveResponseAndData_whenItIsNotHTTPResponse() throws {
        let response = URLResponse()
        let data = Data()
        let expected = NetworkableError.unexpectedResponse(response, data)

        XCTAssertThrowsError(
            try sut.didReceive(response: response, data: data),
            "expected throwing \(expected)."
        ) { (error: Error) in
            XCTAssertEqual(error as! NetworkableError, expected)
        }
    }

    func test_didReceiveResponseAndData_whenStatusCodeIsUnacceptable() throws {
        let statusCode = acceptableStatusCodes.upperBound + 1
        let response = makeResponse(statusCode: statusCode)
        let data = Data()
        let expected = NetworkableError.unacceptableStatusCode(response, data)

        XCTAssertThrowsError(
            try sut.didReceive(response: response, data: data),
            "expected throwing \(expected)."
        ) { (error: Error) in
            XCTAssertEqual(error as! NetworkableError, expected)
        }
    }

    func test_didReceiveResponseAndData() throws {
        let response = makeResponse(statusCode: acceptableStatusCodes.lowerBound)
        
        XCTAssertNoThrow(try sut.didReceive(response: response, data: Data()))
    }
    
    // MARK: Test Cases - didReceive(error:of:)
    
    func didReceive(error: Error, of request: URLRequest) {
        sut.didReceive(error: DummyError(), of: request)
    }
}

extension StatusCodeValidationMiddlewareTests {
    // MARK: Utilities
    
    private func makeURL() -> URL {
        URL(string: "https://apple.com")!
    }
    
    private func makeRequest() -> URLRequest {
        URLRequest(url: makeURL())
    }
    
    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: makeURL(),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
    }
}

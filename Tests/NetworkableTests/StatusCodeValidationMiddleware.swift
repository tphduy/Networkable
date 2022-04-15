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
    
    var url: URL!
    var request: URLRequest!
    var acceptableStatusCodes: ResponseStatusCodes!
    var sut: StatusCodeValidationMiddleware!
    
    // MARK: Life Cycle

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        acceptableStatusCodes = .success
        sut = StatusCodeValidationMiddleware(acceptableStatusCodes: acceptableStatusCodes)
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        acceptableStatusCodes = nil
        sut = nil
    }
    
    // MARK: Test Cases - Init
    
    func test_init() throws {
        XCTAssertEqual(sut.acceptableStatusCodes, acceptableStatusCodes)
    }
    
    // MARK: Test Cases - prepare(request:)
    
    func test_prepareRequest() throws {
        XCTAssertEqual(request, try sut.prepare(request: request))
    }
    
    // MARK: Test Cases - willSend(request:)
    
    func test_willSendRequest() throws {
        XCTAssertNoThrow(sut.willSend(request: request))
    }
    
    // MARK: Test Cases - didReceive(response:data)

    func test_didReceiveResponseAndData_whenItIsNotHTTPResponse() throws {
        let response = URLResponse()
        let expected = NetworkableError.unexpectedResponse(response)

        XCTAssertThrowsError(
            try sut.didReceive(response: response, data: Data()),
            "expected throwing \(expected)."
        ) { (error: Error) in
            XCTAssertEqual(error as! NetworkableError, expected)
        }
    }

    func test_didReceiveResponseAndData_whenStatusCodeIsUnacceptable() throws {
        let statusCode = acceptableStatusCodes.upperBound + 1
        let response = makeResponse(statusCode: statusCode)
        let expected = NetworkableError.unacceptableStatusCode(statusCode, response)

        XCTAssertThrowsError(
            try sut.didReceive(response: response, data: Data()),
            "expected throwing \(expected)."
        ) { (error: Error) in
            XCTAssertEqual(error as! NetworkableError, expected)
        }
    }

    func test_didReceiveResponseAndData() throws {
        let response = makeResponse(statusCode: acceptableStatusCodes.lowerBound)
        XCTAssertNoThrow(try sut.didReceive(response: response, data: Data()))
    }
}

extension StatusCodeValidationMiddlewareTests {
    // MARK: Utilities
    
    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

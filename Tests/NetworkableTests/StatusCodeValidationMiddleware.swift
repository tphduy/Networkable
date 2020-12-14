//
//  DefaultStatusCodeValidationMiddlewareTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/14/20.
//

import XCTest
@testable import Networkable

final class StatusCodeValidationMiddlewareTests: XCTestCase {
    
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var acceptableStatusCodes: ResponseStatusCodes!
    var sut: StatusCodeValidationMiddleware!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        acceptableStatusCodes = .success
        sut = StatusCodeValidationMiddleware(acceptableStatusCodes: acceptableStatusCodes)
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        response = nil
        acceptableStatusCodes = nil
        sut = nil
    }
    
    // MARK: - Init
    
    func testInit() throws {
        XCTAssertEqual(sut.acceptableStatusCodes, acceptableStatusCodes)
    }
    
    // MARK: - Prepare Request
    
    func testPrepareRequest() throws {
        XCTAssertEqual(try sut.prepare(request: request), request)
    }
    
    // MARK: - Will Send Request
    
    func testWillSendRequest() throws {
        XCTAssertNoThrow(sut.willSend(request: request))
    }
    
    // MARK: - Did Receive Response And Data

    func testDidReceiveResponseAndData_whenItIsNotHTTPResponse() throws {
        response = URLResponse()
        let expected = NetworkableError.unexpectedResponse(response)
        let expectedMessage = "expected throwing \(expected)"

        XCTAssertThrowsError(try sut.didReceive(response: response, data: Data()), expectedMessage) { (error: Error) in
            XCTAssertEqual(error as! NetworkableError, expected)
        }
    }

    func testDidReceiveResponseAndData_whenStatusCodeIsUnacceptable() throws {
        let statusCode = acceptableStatusCodes.upperBound + 1
        response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        let expected = NetworkableError.unacceptableStatusCode(statusCode, response)
        let expectedMessage = "expected throwing \(expected)"

        XCTAssertThrowsError(try sut.didReceive(response: response, data: Data()), expectedMessage) { (error: Error) in
            XCTAssertEqual(error as! NetworkableError, expected)
        }
    }

    func testDidReceiveResponseAndData() throws {
        XCTAssertNoThrow(try sut.didReceive(response: response, data: Data()))
    }
}

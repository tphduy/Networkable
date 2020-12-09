//
//  DefaultCodeValidationMiddlewareTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/14/20.
//

import XCTest
@testable import Networkable

final class DefaultCodeValidationMiddlewareTests: XCTestCase {
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var data: Data!
    var codes: ResponseStatusCodes!
    var sut: DefaultCodeValidationMiddleware!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)
        data = "data".data(using: .utf8)
        codes = .success
        sut = DefaultCodeValidationMiddleware(acceptableCodes: codes)
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        response = nil
        data = nil
        codes = nil
        sut = nil
    }

    func testDidReceiveResponseThrowUnexpectedResponse() throws {
        response = URLResponse()
        let expected = NetworkableError.unexpectedResponse(response)
        let expectedMessage = "expected throwing \(expected)"

        XCTAssertThrowsError(try sut.didReceive(response: response, data: Data()), expectedMessage) { (error: Error) in
            XCTAssertEqual(error as! NetworkableError, expected)
        }
    }

    func testDidReceiveResponseThrowUnacceptedCode() throws {
        let code = 400
        response = HTTPURLResponse(
            url: url,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil)
        let expected = NetworkableError.unacceptableCode(code, response)
        let expectedMessage = "expected throwing \(expected)"

        XCTAssertThrowsError(try sut.didReceive(response: response, data: Data()), expectedMessage) { (error: Error) in
            XCTAssertEqual(error as! NetworkableError, expected)
        }
    }

    func testDidReceiveResponse() throws {
        XCTAssertNoThrow(try sut.didReceive(response: response, data: Data()))
    }
}

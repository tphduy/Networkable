//
//  DefaultCodeValidationMiddlewareTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/14/20.
//

@testable import Networking
import XCTest

final class DefaultCodeValidationMiddlewareTests: XCTestCase {
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var data: Data!
    var codes: HTTPCodes!
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
        let expected = NetworkingError.unexpectedResponse(response)
        let expectedMessage = "expected throwing \(expected)"

        XCTAssertThrowsError(try sut.didReceive(response: response), expectedMessage) { (error: Error) in
            XCTAssertEqual(error as! NetworkingError, expected)
        }
    }

    func testDidReceiveResponseThrowUnacceptedCode() throws {
        let code = 400
        response = HTTPURLResponse(
            url: url,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil)
        let expected = NetworkingError.unacceptableCode(code, response)
        let expectedMessage = "expected throwing \(expected)"

        XCTAssertThrowsError(try sut.didReceive(response: response), expectedMessage) { (error: Error) in
            XCTAssertEqual(error as! NetworkingError, expected)
        }
    }

    func testDidReceiveResponse() throws {
        XCTAssertNoThrow(try sut.didReceive(response: response))
    }
}

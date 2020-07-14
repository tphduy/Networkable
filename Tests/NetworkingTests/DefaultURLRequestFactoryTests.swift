//
//  DefaultURLRequestFactoryTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/12/20.
//

import XCTest
@testable import Networking

final class DefaultURLRequestFactoryTests: XCTestCase {
    var rawURL: String!
    var endpoint: SpyEndpoint!
    var sut: DefaultURLRequestFactory!

    override func setUpWithError() throws {
        rawURL = "https://test.com"
        endpoint = SpyEndpoint()
        endpoint.stubbedHeaders = ["key": "value"]
        endpoint.stubbedPath = "/path?string=\"String\"&int=0&bool=true"
        endpoint.stubbedMethod = .get
        endpoint.stubbedBodyResult = "data".data(using: .utf8)!

        sut = DefaultURLRequestFactory(rawURL: rawURL)
    }

    override func tearDownWithError() throws {
        rawURL = nil
        endpoint = nil
        sut = nil
    }

    func testInit() {
        XCTAssertEqual(
            sut.rawURL,
            rawURL)
    }

    func testMakeWithEndpointResultURL() throws {
        let request = try sut.make(endpoint: endpoint)
        let expected = rawURL
            + endpoint
                .path
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

        XCTAssertEqual(
            request.url?.absoluteString,
            expected)
    }

    func testMakeWithEndpointResultURLWhenURLIsInvalid() throws {
        rawURL = ""
        sut = DefaultURLRequestFactory(rawURL: rawURL)
        let expectedError = NetworkingError.invalidURL("")

        XCTAssertThrowsError(
            try sut.make(endpoint: endpoint),
            "Expected throwing \(expectedError)") { (error: Error) in
                XCTAssertTrue(error is NetworkingError)
                XCTAssertEqual(
                    error as! NetworkingError,
                    expectedError)
        }
    }

    func testMakeWithEndpointResultMethod() throws {
        try Networking.Method.allCases.forEach { (method: Networking.Method) in
            endpoint.stubbedMethod = method
            let request = try sut.make(endpoint: endpoint)
            XCTAssertEqual(
                request.httpMethod,
                method.rawValue.uppercased())
        }
    }

    func testMakeWithEndpointResultHeader() throws {
        let headers = [
            "foo": "bar",
            "fizz": ""
        ]
        endpoint.stubbedHeaders = headers

        XCTAssertEqual(
            try sut.make(endpoint: endpoint).allHTTPHeaderFields,
            headers)
    }

    func testMakeWithEndpointResultHeaderWhenHeaderIsNil() throws {
        endpoint.stubbedHeaders = nil
        let headers = try sut.make(endpoint: endpoint).allHTTPHeaderFields
        XCTAssertTrue(headers!.isEmpty)
    }

    func testMakeWithEndpointResultBody() throws {
        let body = "[\"body\":\"body\"".data(using: .utf8)
        endpoint.stubbedBodyResult = body

        let request = try sut.make(endpoint: endpoint)

        XCTAssertEqual(
            request.httpBody,
            body)
    }

    func testMakeWithEndpointResultBodyWhenThrowError() throws {
        let dummyError = DummyError()
        endpoint.stubbedBodyError = dummyError
        XCTAssertThrowsError(
            try sut.make(endpoint: endpoint),
            "Expecting throwing \(dummyError)") { (error: Error) in
                XCTAssertTrue(error is DummyError)
                XCTAssertEqual(
                    error as! DummyError,
                    dummyError)
        }
    }
}

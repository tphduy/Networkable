//
//  URLRequestLoggingTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest
@testable import Networking

final class URLRequestLoggingTests: XCTestCase {
    var url: URL!
    var method: String!
    var headers: [String: String]!
    var body: Data!
    var sut: URLRequest!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        method = "GET"
        headers = ["foo": "bar"]
        body = """
        {"data":"some data"}
        """.data(using: .utf8)

        sut = URLRequest(url: url)
        sut.httpMethod = method
        sut.allHTTPHeaderFields = headers
        sut.httpBody = body
    }

    override func tearDownWithError() throws {
        url = nil
        method = nil
        headers = nil
        body = nil
        sut = nil
    }

    func testLoggingWhenMissingURL() throws {
        sut.url = nil
        let logging = sut.logging()
        XCTAssertTrue(logging.isEmpty)
    }

    func testLoggingWhenMissingMethod() throws {
        sut = URLRequest(url: url)
        let logging = sut.logging()
        XCTAssertTrue(logging.contains("-X GET"))
    }

    func testLoggingWhenMissingHeader() throws {
        sut = URLRequest(url: url)
        let logging = sut.logging()
        XCTAssertFalse(logging.contains("-H"))
    }

    func testLoggingWhenMissingBody() throws {
        sut.httpBody = nil
        let logging = sut.logging()
        XCTAssertFalse(logging.contains("-d"))
    }

    func testLogging() {
        let logging = sut.logging()
        XCTAssertTrue(logging.contains("curl -v"))
        XCTAssertTrue(logging.contains("-X GET"))
        XCTAssertTrue(logging.contains("-H \"foo\": \"bar\""))
        XCTAssertTrue(logging.contains("-d \"{\"data\":\"some data\"}\""))
        XCTAssertTrue(logging.contains(url.absoluteString))
    }
}

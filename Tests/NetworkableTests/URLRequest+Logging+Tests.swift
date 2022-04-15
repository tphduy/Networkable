//
//  URLRequest+Logging+Tests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest
@testable import Networkable

final class URLRequest_Logging_Tests: XCTestCase {
    // MARK: Misc
    
    var url: URL!
    var method: String!
    var headers: [String: String]!
    var body: Data!
    var sut: URLRequest!
    
    // MARK: Life Cycle

    override func setUpWithError() throws {
        sut = URLRequest(url: URL(string: "https://apple.com?foo=bar&id=1")!)
        sut.httpMethod = "GET"
        sut.allHTTPHeaderFields = ["foo": "bar"]
        sut.httpBody = #"{"data":"some data"}"#.data(using: .utf8)
    }

    override func tearDownWithError() throws {
        url = nil
        method = nil
        headers = nil
        body = nil
        sut = nil
    }
    
    // MARK: Test Cases - logging()

    func test_logging_whenURLIsNone() throws {
        sut.url = nil
        
        let logging = sut.logging()
        
        XCTAssertTrue(logging.isEmpty)
    }

    func test_logging_whenMethodIsNone() throws {
        sut.httpMethod = nil
        
        let logging = """
        🚀 Request: https://apple.com?foo=bar&id=1
            -X GET
            -H "foo": "bar"
            -d "{"data":"some data"}"
        """
        
        XCTAssertEqual(sut.logging(), logging)
    }
    
    func test_logging_whenHeadersAreNone() throws {
        sut.allHTTPHeaderFields = nil
        
        let logging = """
        🚀 Request: https://apple.com?foo=bar&id=1
            -X GET
            -H "foo": "bar"
            -d "{"data":"some data"}"
        """
        
        XCTAssertEqual(sut.logging(), logging)
    }
    
    func test_logging_whenBodyIsNone() throws {
        sut.httpBody = nil
        
        let logging = """
        🚀 Request: https://apple.com?foo=bar&id=1
            -X GET
            -H "foo": "bar"
        """
        
        XCTAssertEqual(sut.logging(), logging)
    }
    
    func test_logging() throws {
        let logging = """
        🚀 Request: https://apple.com?foo=bar&id=1
            -X GET
            -H "foo": "bar"
            -d "{"data":"some data"}"
        """
        
        XCTAssertEqual(sut.logging(), logging)
    }
}

//
//  URLRequest+Logging+Tests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest
@testable import Networkable

final class URLRequest_Logging_Tests: XCTestCase {
    
    var url: URL!
    var method: String!
    var headers: [String: String]!
    var body: Data!
    var sut: URLRequest!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com?foo=bar&id=1")!
        method = "GET"
        headers = ["foo": "bar"]
        body = #"{"data":"some data"}"#.data(using: .utf8)
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
    
    // MARK: - Logging

    func testLogging_whenMissingURL_itReturnAnEmptyString() throws {
        sut.url = nil
        
        let logging = sut.logging()
        
        XCTAssertTrue(logging.isEmpty)
    }

    func testLogging_whenMissingMethod_itReturnAStringRepresentingItself() throws {
        sut.httpMethod = nil
        let logging = """
        🚀 Request: https://apple.com?foo=bar&id=1\n\t-X GET\n\t-H "foo": "bar"\n\t-d "{"data":"some data"}"
        """
        
        XCTAssertEqual(sut.logging(), logging)
    }
    
    func testLogging_whenMissingHeader_itReturnAStringRepresentingItself() throws {
        sut.allHTTPHeaderFields = nil
        let logging = """
        🚀 Request: https://apple.com?foo=bar&id=1\n\t-X GET\n\t-H "foo": "bar"\n\t-d "{"data":"some data"}"
        """
        
        XCTAssertEqual(sut.logging(), logging)
    }
    
    func testLogging_whenMissingBody_itReturnAStringRepresentingItself() throws {
        sut.httpBody = nil
        let logging = """
        🚀 Request: https://apple.com?foo=bar&id=1\n\t-X GET\n\t-H "foo": "bar"
        """
        
        XCTAssertEqual(sut.logging(), logging)
    }
    
    func testLogging_itReturnAStringRepresentingItself() throws {
        let logging = """
        🚀 Request: https://apple.com?foo=bar&id=1\n\t-X GET\n\t-H "foo": "bar"\n\t-d "{"data":"some data"}"
        """
        
        XCTAssertEqual(sut.logging(), logging)
    }
}

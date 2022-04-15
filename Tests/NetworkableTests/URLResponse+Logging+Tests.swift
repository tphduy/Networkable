//
//  URLResponse+Logging+Tests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest

final class URLResponse_Logging_Tests: XCTestCase {
    // MARK: Test Cases - logging()
    
    func test_logging_whenURLIsAbsent() throws {
        let response = HTTPURLResponse()
        
        XCTAssertTrue(response.logging().isEmpty)
    }
    
    func test_logging_() throws {
        let response = HTTPURLResponse(
            url: URL(string: "http://apple.com/foo/bar?id=1")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Foo": "Bar", "Fizz": "Buzz"])!
        let logging = """
        📩 Response: http://apple.com/foo/bar?id=1
            -H 200
            -H "Fizz: Buzz"
            -H "Foo: Bar"
        """
        XCTAssertEqual(response.logging(), logging)
    }
}

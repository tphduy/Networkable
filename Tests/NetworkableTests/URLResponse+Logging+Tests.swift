//
//  URLResponse+Logging+Tests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest

final class URLResponse_Logging_Tests: XCTestCase {
    
    func testLogging_whenURLIsAbsent_itReturnAnEmptyString() throws {
        let response = URLResponse()
        
        XCTAssertTrue(response.logging().isEmpty)
    }
    
    func testLogging_whenURLIsValid_itReturnAStringRepresentingItself() throws {
        let url = URL(string: "http://apple.com/foo/bar?id=1")!
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let logging = #"📩 Response: http://apple.com/foo/bar?id=1"#
        
        XCTAssertEqual(response.logging(), logging)
    }
    
    func testLogging_whenItIsHTTPURLResponse_andURLIsAbsent_itReturnAnEmptyString() throws {
        let response = HTTPURLResponse()
        
        XCTAssertTrue(response.logging().isEmpty)
    }
    
    func testLogging_whenItIsHTTPURLResponse_andURLIsValid_itReturnAStringRepresentingItself() throws {
        let url = URL(string: "http://apple.com/foo/bar?id=1")!
        let statusCode = 200
        let headers = [
            "Foo": "Bar"
        ]
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers)!
        let logging = """
        📩 Response: http://apple.com/foo/bar?id=1\n\t-H 200\n\t-H "Foo: Bar"
        """
        
        XCTAssertEqual(response.logging(), logging)
    }
}

//
//  DefaultLoggingMiddlewareTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest
import os.log
@testable import Networking

@available(iOS 12.0, OSX 10.14, *)
final class DefaultLoggingMiddlewareTests: XCTestCase {
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var data: Data!
    var type: OSLogType!
    var log: OSLog!

    var sut: DefaultLoggingMiddleware!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        data = "data".data(using: .utf8)
        type = .info
        log = OSLog(subsystem: "com.duytph.UnitTest", category: "\(Self.self)")

        sut = DefaultLoggingMiddleware(type: type, log: log)
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        response = nil
        data = nil
        sut = nil
    }

    func testWillSendRequest() throws {
        XCTAssertNoThrow(sut.willSend(request: request))
    }

    func testDidReceiveResponse() throws {
        XCTAssertNoThrow(try sut.didReceive(response: response))
    }

    func testDidReceiveData() throws {
        XCTAssertNoThrow(try sut.didReceive(data: data))
    }
}

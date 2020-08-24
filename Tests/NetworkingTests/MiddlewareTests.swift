//
//  MiddlewareTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest
@testable import Networking

fileprivate final class EmptyMiddleware: Middleware {}

final class MiddlewareTests: XCTestCase {
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var data: Data!

    fileprivate var sut: EmptyMiddleware!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        data = "data".data(using: .utf8)

        sut = EmptyMiddleware()
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        response = nil
        data = nil
        sut = nil
    }

    func testprepareRequest() throws {
        let preparedRequest = try sut.prepare(request: request)
        XCTAssertEqual(preparedRequest, request)
    }

    func testwillSendRequest() throws {
        XCTAssertNoThrow(sut.willSend(request: request))
    }

    func testDidReceiveResponseData() throws {
        XCTAssertNoThrow(try sut.didReceive(response: response, data: data))
    }
}

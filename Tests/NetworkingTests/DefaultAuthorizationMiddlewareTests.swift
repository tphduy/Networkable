//
//  DefaultAuthorizationMiddlewareTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import XCTest
@testable import Networking

final class DefaultAuthorizationMiddlewareTests: XCTestCase {
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var data: Data!
    var type: SpyAuthorizationType!
    var sut: DefaultAuthorizationMiddleware!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        data = "data".data(using: .utf8)
        type = SpyAuthorizationType()
        type.stubbedKey = "key"
        type.stubbedValue = "value"

        sut = DefaultAuthorizationMiddleware(type: type)
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        response = nil
        data = nil
        type = nil
        sut = nil
    }

    func testInit() {
        XCTAssertEqual(sut.type as? SpyAuthorizationType, type)
    }

    func testPrepareRequest() throws {
        let preparedRequest = try sut.prepare(request: request)
        let headers = preparedRequest.allHTTPHeaderFields!
        XCTAssertTrue(headers.contains(where: { (header) -> Bool in
            header.key == type.key && header.value == header.value
        }))
    }
}

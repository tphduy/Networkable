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
    var authorization: SpyAuthorizationType!
    var sut: DefaultAuthorizationMiddleware!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        data = "data".data(using: .utf8)
        authorization = SpyAuthorizationType()
        authorization.stubbedKey = "key"
        authorization.stubbedValue = "value"
        authorization.stubbedPlace = .header

        sut = DefaultAuthorizationMiddleware(authorization: authorization)
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        response = nil
        data = nil
        authorization = nil
        sut = nil
    }

    func testInit() {
        XCTAssertEqual(sut.authorization as? SpyAuthorizationType, authorization)
    }

    func testPrepareRequestWhenPlaceIsHeader() throws {
        authorization.stubbedPlace = .header
        let preparedRequest = try sut.prepare(request: request)
        let headers = preparedRequest.allHTTPHeaderFields!
        XCTAssertTrue(headers.contains(where: { (header) -> Bool in
            header.key == authorization.key && header.value == authorization.value
        }))
    }
    
    func testPrepareRequestWhenPlaceIsQuery() throws {
        authorization.stubbedPlace = .query
        let preparedRequest = try sut.prepare(request: request)
        let expected = authorization.stubbedKey + "=" + authorization.stubbedValue
        XCTAssertTrue(preparedRequest.url!.path.contains(expected))
    }
    
    func testDidReceiveResponseAndData() {
        XCTAssertNoThrow(try sut.didReceive(response: response, data: data))
    }
}

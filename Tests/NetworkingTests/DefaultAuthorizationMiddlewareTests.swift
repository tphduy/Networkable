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
        url = URL(string: "https://apple.com?id=1")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        data = "data".data(using: .utf8)
        authorization = SpyAuthorizationType()
        authorization.stubbedKey = "key"
        authorization.stubbedValue = "value"
        authorization.stubbedPlace = .header

        sut = DefaultAuthorizationMiddleware(authorization: { self.authorization })
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        response = nil
        data = nil
        authorization = nil
        sut = nil
    }

    func testInit() throws {
        XCTAssertEqual(sut.authorization() as? SpyAuthorizationType, authorization)
    }

    func testPrepareRequestWhenKeyIsEmptyAndPlaceIsHeader() throws {
        authorization.stubbedKey = ""
        authorization.stubbedPlace = .header
        let preparedRequest = try sut.prepare(request: request)
        XCTAssertNil(preparedRequest.allHTTPHeaderFields)
    }

    func testPrepareRequestWhenKeyIsEmptyAndPlaceIsQuery() throws {
        authorization.stubbedKey = ""
        authorization.stubbedPlace = .query
        let originalQuery = request.url?.query
        let preparedRequest = try sut.prepare(request: request)
        XCTAssertEqual(originalQuery, preparedRequest.url?.query)
    }

    func testPrepareRequestWhenValueIsEmptyAndPlaceIsHeader() throws {
        authorization.stubbedValue = ""
        authorization.stubbedPlace = .header
        let preparedRequest = try sut.prepare(request: request)
        XCTAssertNil(preparedRequest.allHTTPHeaderFields)
    }

    func testPrepareRequestWhenValueIsEmptyAndPlaceIsQuery() throws {
        authorization.stubbedValue = ""
        authorization.stubbedPlace = .query
        let preparedRequest = try sut.prepare(request: request)
        XCTAssertTrue(preparedRequest.url!.path.isEmpty)
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
        XCTAssertTrue(preparedRequest.url!.query!.contains(expected))
    }
}

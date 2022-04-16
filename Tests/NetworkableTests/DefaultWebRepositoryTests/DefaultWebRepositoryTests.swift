//
//  DefaultRepositoryTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

import XCTest
@testable import Networkable

class DefaultWebRepositoryTests: XCTestCase {
    // MARK: Misc

    var request: URLRequest!
    var response: URLResponse!
    var data: Data!
    var endpoint: SpyEndpoint!
    var requestBuilder: SpyURLRequestBuildable!
    var middleware: SpyMiddleware!
    var session: URLSession!
    var sut: DefaultWebRepository!
    
    // MARK: Life Cycle
    
    override func setUpWithError() throws {
        request = makeRequest()
        response = makeResponse(statusCode: 200)
        data = """
        {"foo":"bar","fizz":"buzz"}
        """.data(using: .utf8)!
        endpoint = makeEndpoint()
        requestBuilder = makeRequestBuilder()
        middleware = makeMiddleware()
        session = makeSession()
        sut = DefaultWebRepository(requestBuilder: requestBuilder, middlewares: [middleware], session: session)
    }
    
    override func tearDownWithError() throws {
        session.tearDown()
        request = nil
        response = nil
        data = nil
        endpoint = nil
        requestBuilder = nil
        middleware = nil
        session = nil
        sut = nil
    }
    
    // MARK: Test Cases - init(requestBuilder:middlewares:session:)
    
    func test_init() throws {
        XCTAssertIdentical(sut.requestBuilder as! SpyURLRequestBuildable, requestBuilder)
        XCTAssertEqual(sut.middlewares as! [SpyMiddleware], [middleware])
        XCTAssertEqual(sut.session, session)
    }
}

extension DefaultWebRepositoryTests {
    // MARK: Utilities
    
    private func makeRequest() -> URLRequest {
        URLRequest(url: URL(string: "https://www.foo.bar")!)
    }
    
    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
    }
    
    private func makeEndpoint() -> SpyEndpoint {
        let result = SpyEndpoint()
        result.stubbedUrl = "/foo/bar"
        result.stubbedMethod = .get
        result.stubbedHeaders = ["Foo": "Bar"]
        result.stubbedBodyResult = #"{"foo":"bar"}"#.data(using: .utf8)!
        return result
    }
    
    private func makeRequestBuilder() -> SpyURLRequestBuildable {
        let result = SpyURLRequestBuildable()
        result.stubbedMakeResult = request
        return result
    }
    
    private func makeMiddleware() -> SpyMiddleware {
        let result = SpyMiddleware()
        result.stubbedPrepareResult = request
        return result
    }
    
    private func makeSession() -> URLSession {
        let result = URLSession.stubbed
        result.set(stubbedData: data, for: request)
        result.set(stubbedResponse: response, for: request)
        return result
    }
}

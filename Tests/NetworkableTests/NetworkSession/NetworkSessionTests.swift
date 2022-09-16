//
//  NetworkSessionTests.swift
//  
//
//  Created by Duy Trần on 20/09/2022.
//

import XCTest
@testable import Networkable

class NetworkSessionTests: XCTestCase {
    // MARK: Misc
    
    var urlRequest: URLRequest!
    var urlResponse: HTTPURLResponse!
    var data: Data!
    var requestBuilder: SpyURLRequestBuilder!
    var middleware: SpyMiddleware!
    var session: URLSession!
    var sut: NetworkSession!
    
    // MARK: Life Cycle
    
    override func setUpWithError() throws {
        urlRequest = makeURLRequest()
        urlResponse = makeURLResponse()
        data = makeData()
        requestBuilder = makeRequestBuilder()
        middleware = makeMiddleware()
        session = .stubbed
        sut = NetworkSession(
            requestBuilder: requestBuilder,
            middlewares: [middleware],
            session: session)
        
        bootstrapSession()
    }
    
    override func tearDownWithError() throws {
        urlRequest = nil
        urlResponse = nil
        data = nil
        requestBuilder = nil
        middleware = nil
        session = nil
        sut = nil
        
        resetSession()
    }
    
    // MARK: Test Cases - init(requestBuilder:middlewares:session)
    
    func test_init() throws {
        XCTAssertIdentical(sut.requestBuilder as? SpyURLRequestBuilder, requestBuilder)
        XCTAssertEqual(sut.middlewares as? [SpyMiddleware], [middleware])
        XCTAssertEqual(sut.session, session)
    }
}

extension NetworkSessionTests {
    // MARK: Utilities
    
    private func makeURL() -> URL {
        URL(string: "https://foo.bar")!
    }
    
    func makeRequest() -> Request {
        SpyRequest()
    }
    
    func makeURLRequest() -> URLRequest {
        URLRequest(url: makeURL())
    }
    
    func makeURLResponse() -> HTTPURLResponse {
        let result = HTTPURLResponse(
            url: makeURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["foo": "bar"])!
        return result
    }
    
    func makeData() -> Data {
        """
        {"foo":"bar"}
        """.data(using: .utf8)!
    }
    
    func makeRequestBuilder() -> SpyURLRequestBuilder {
        let result = SpyURLRequestBuilder()
        result.stubbedBuildResult = urlRequest
        return result
    }
    
    func makeMiddleware() -> SpyMiddleware {
        let result = SpyMiddleware()
        result.stubbedPrepareResult = urlRequest
        return result
    }
    
    func bootstrapSession() {
        StubbedURLProtocol.stubbedResponse[urlRequest] = urlResponse
        StubbedURLProtocol.stubbedData[urlRequest] = data
    }
    
    func resetSession() {
        StubbedURLProtocol.reset()
    }
}

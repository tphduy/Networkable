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
    var endpoint: SpyEndpoint!
    var requestBuilder: SpyURLRequestBuildable!
    var middleware: SpyMiddleware!
    var session: URLSession!
    var sut: DefaultWebRepository!
    
    // MARK: Life Cycle
    
    override func setUpWithError() throws {
        request = makeRequest()
        endpoint = makeEndpoint()
        requestBuilder = makeRequestBuilder()
        middleware = makeMiddleware()
        session = makeSession()
        sut = DefaultWebRepository(requestBuilder: requestBuilder, middlewares: [middleware], session: session)
    }
    
    override func tearDownWithError() throws {
        session.tearDown()
        request = nil
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
    
    // MARK: Test Cases - call(to:resultQueue:decoder:promise:)
    
    func test_call_whenPreparing_andMiddlewareThrowError() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error as DummyError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_call_whenCompleted_andThrowingNetworkingError() throws {
        let expected = DummyError.self
        session.set(stubbedResponseError: expected.init(), for: request)
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error as NSError) = result else { return XCTFail(message) }
            XCTAssertTrue(error.domain.contains(String(describing: expected)))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_call_whenCompleted_andThrowingDecodingError() throws {
        session.set(stubbedData: "invalid JSON".data(using: .utf8), for: request)
        
        let message = "expect throwing \(DecodingError.self)"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error) = result else { return XCTFail(message) }
            XCTAssertTrue(error is DecodingError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_call_whenCompleted_andThrowingMiddlewareError() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveError = expected
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error as DummyError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_call_whenCompleted_withNoResponse() throws {
        let expected = NetworkableError.empty
        session.set(stubbedResponse: nil, for: request)
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error as NetworkableError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_call_whenCompleted_withNoData() throws {
        session.set(stubbedData: nil, for: request)
        
        let message = "expect throwing \(DecodingError.self)"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error) = result else { return XCTFail(message) }
            XCTAssertTrue(error is DecodingError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_call_whenCompleted() throws {
        let message = "expect throwing no error"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case .success = result else { return XCTFail(message) }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_call_whenCompleted_onGlobalQueue() {
        let message = "expect promise is executed on global background thread."
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint, resultQueue: .global(qos: .background)) { (result: Result<DummyCodable, Error>) in
            XCTAssertTrue(Thread.current.qualityOfService == .background)
            guard case .success = result else { return XCTFail(message) }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
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
        let data = """
        {"foo":"bar","fizz":"buzz"}
        """.data(using: .utf8)!
        let result = URLSession.stubbed
        result.set(stubbedData: data, for: request)
        result.set(stubbedResponse: makeResponse(statusCode: 200), for: request)
        return result
    }
}

//
//  URLRequestBuilderTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/12/20.
//

import XCTest
@testable import Networkable

final class URLRequestBuilderTests: XCTestCase {
    // MARK: Misc
    
    private var request: SpyRequest!
    private var baseURL: URL!
    private var cachePolicy: URLRequest.CachePolicy!
    private var timeoutInterval: TimeInterval!
    private var sut: URLRequestBuilder!
    
    // MARK: Life Cycle

    override func setUpWithError() throws {
        request = makeRequest()
        baseURL = URL(string: "https://api.foo.bar")
        cachePolicy = .useProtocolCachePolicy
        timeoutInterval = 60
        sut = URLRequestBuilder(
            baseURL: baseURL,
            cachePolicy: cachePolicy,
            timeoutInterval: timeoutInterval)
    }

    override func tearDownWithError() throws {
        request = nil
        baseURL = nil
        cachePolicy = nil
        timeoutInterval = nil
        sut = nil
    }
    
    // MARK: Test Cases - init(baseURL:cachePolicy:timeoutInterval:)

    func test_init() {
        XCTAssertEqual(sut.baseURL, baseURL)
        XCTAssertEqual(sut.cachePolicy, cachePolicy)
        XCTAssertEqual(sut.timeoutInterval, timeoutInterval)
    }
    
     // MARK: Test Cases - build(request:)
    
    func test_build_whenURLIsInvalid() throws {
        request.stubbedUrl = ""
        
        XCTAssertThrowsError(try sut.build(request: request)) { (error: Error) in
            XCTAssertEqual(
                error as! NetworkableError,
                .invalidURL(request.stubbedUrl, relativeURL: baseURL))
        }
    }
    
    func test_build_whenURLIsAbsoblute() throws {
        request.stubbedUrl = "https://www.fizz.buzz/path?string=String&int=0&bool=true"
        
        let result = try sut.build(request: request)
        
        XCTAssertNotNil(sut.baseURL)
        XCTAssertNotEqual(result.url?.host, sut.baseURL?.host)
        XCTAssertEqual(result.url, URL(string: request.stubbedUrl))
        XCTAssertEqual(result.cachePolicy, cachePolicy)
        XCTAssertEqual(result.timeoutInterval, timeoutInterval)
        XCTAssertEqual(result.allHTTPHeaderFields, request.stubbedHeaders)
        XCTAssertEqual(result.httpMethod, request.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(result.httpBody, request.stubbedBodyResult)
    }
    
    func test_build_whenURLIsRelative_andBaseURLIsSome() throws {
        request.stubbedUrl = "/path?string=String&int=0&bool=true"
        
        let result = try sut.build(request: request)
        
        XCTAssertNotNil(sut.baseURL)
        XCTAssertEqual(result.url?.host, sut.baseURL?.host)
        XCTAssertEqual(result.url, URL(string: request.stubbedUrl, relativeTo: baseURL)?.absoluteURL)
        XCTAssertEqual(result.cachePolicy, cachePolicy)
        XCTAssertEqual(result.timeoutInterval, timeoutInterval)
        XCTAssertEqual(result.allHTTPHeaderFields, request.stubbedHeaders)
        XCTAssertEqual(result.httpMethod, request.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(result.httpBody, request.stubbedBodyResult)
    }
    
    func test_build_whenURLIsRelative_andBaseURLIsNone() throws {
        request.stubbedUrl = "/path?string=String&int=0&bool=true"
        sut.baseURL = nil
        
        let result = try sut.build(request: request)
        
        XCTAssertEqual(result.url, URL(string: request.stubbedUrl))
        XCTAssertEqual(result.cachePolicy, cachePolicy)
        XCTAssertEqual(result.timeoutInterval, timeoutInterval)
        XCTAssertEqual(result.allHTTPHeaderFields, request.stubbedHeaders)
        XCTAssertEqual(result.httpMethod, request.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(result.httpBody, request.stubbedBodyResult)
    }
    
    func test_build_whenBodyThrowsError() throws {
        let bodyError = DummyError()
        request.stubbedBodyError = bodyError
        
        XCTAssertThrowsError(try sut.build(request: request)) { (error: Error) in
            XCTAssertEqual(error as? DummyError, bodyError)
        }
    }
}

extension URLRequestBuilderTests {
    // MARK: Utilities
    
    private func makeRequest() -> SpyRequest {
        let result = SpyRequest()
        result.stubbedHeaders = ["key": "value"]
        result.stubbedUrl = #"/path?string=String&int=0&bool=true"#
        result.stubbedMethod = .get
        result.stubbedBodyResult = Data()
        return result
    }
}

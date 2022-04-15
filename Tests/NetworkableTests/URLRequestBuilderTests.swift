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
    
    var endpoint: SpyEndpoint!
    var baseURL: URL!
    var cachePolicy: URLRequest.CachePolicy!
    var timeoutInterval: TimeInterval!
    var sut: URLRequestBuilder!
    
    // MARK: Life Cycle

    override func setUpWithError() throws {
        endpoint = makeEndpoint()
        baseURL = URL(string: "https://api.foo.bar")
        cachePolicy = .useProtocolCachePolicy
        timeoutInterval = 60
        sut = URLRequestBuilder(
            baseURL: baseURL,
            cachePolicy: cachePolicy,
            timeoutInterval: timeoutInterval)
    }

    override func tearDownWithError() throws {
        endpoint = nil
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
    
     // MARK: Test Cases - build(endpoint:)
    
    func test_build_whenURLIsInvalid() throws {
        endpoint.stubbedUrl = ""
        
        XCTAssertThrowsError(try sut.build(endpoint: endpoint)) { (error: Error) in
            XCTAssertEqual(
                error as? NetworkableError,
                .invalidURL(endpoint.stubbedUrl, relativeURL: baseURL))
        }
    }
    
    func test_build_whenURLIsAbsoblute() throws {
        endpoint.stubbedUrl = "https://www.fizz.buzz/path?string=String&int=0&bool=true"
        
        let result = try sut.build(endpoint: endpoint)
        
        XCTAssertNotNil(sut.baseURL)
        XCTAssertNotEqual(result.url?.host, sut.baseURL?.host)
        XCTAssertEqual(result.url, URL(string: endpoint.stubbedUrl))
        XCTAssertEqual(result.cachePolicy, cachePolicy)
        XCTAssertEqual(result.timeoutInterval, timeoutInterval)
        XCTAssertEqual(result.allHTTPHeaderFields, endpoint.stubbedHeaders)
        XCTAssertEqual(result.httpMethod, endpoint.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(result.httpBody, endpoint.stubbedBodyResult)
    }
    
    func test_build_whenURLIsRelative_andBaseURLIsSome() throws {
        endpoint.stubbedUrl = "/path?string=String&int=0&bool=true"
        
        let result = try sut.build(endpoint: endpoint)
        
        XCTAssertNotNil(sut.baseURL)
        XCTAssertEqual(result.url?.host, sut.baseURL?.host)
        XCTAssertEqual(result.url, URL(string: endpoint.stubbedUrl, relativeTo: baseURL)?.absoluteURL)
        XCTAssertEqual(result.cachePolicy, cachePolicy)
        XCTAssertEqual(result.timeoutInterval, timeoutInterval)
        XCTAssertEqual(result.allHTTPHeaderFields, endpoint.stubbedHeaders)
        XCTAssertEqual(result.httpMethod, endpoint.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(result.httpBody, endpoint.stubbedBodyResult)
    }
    
    func test_build_whenURLIsRelative_andBaseURLIsNone() throws {
        endpoint.stubbedUrl = "/path?string=String&int=0&bool=true"
        sut.baseURL = nil
        
        let result = try sut.build(endpoint: endpoint)
        
        XCTAssertEqual(result.url, URL(string: endpoint.stubbedUrl))
        XCTAssertEqual(result.cachePolicy, cachePolicy)
        XCTAssertEqual(result.timeoutInterval, timeoutInterval)
        XCTAssertEqual(result.allHTTPHeaderFields, endpoint.stubbedHeaders)
        XCTAssertEqual(result.httpMethod, endpoint.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(result.httpBody, endpoint.stubbedBodyResult)
    }
    
    func test_build_whenBodyThrowsError() throws {
        let bodyError = DummyError()
        endpoint.stubbedBodyError = bodyError
        
        XCTAssertThrowsError(try sut.build(endpoint: endpoint)) { (error: Error) in
            XCTAssertEqual(error as? DummyError, bodyError)
        }
    }
}

extension URLRequestBuilderTests {
    // MARK: Utilities
    
    private func makeEndpoint() -> SpyEndpoint {
        let result = SpyEndpoint()
        result.stubbedHeaders = ["key": "value"]
        result.stubbedUrl = #"/path?string=String&int=0&bool=true"#
        result.stubbedMethod = .get
        result.stubbedBodyResult = Data()
        return result
    }
}

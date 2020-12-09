//
//  DefaultURLRequestFactoryTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/12/20.
//

import XCTest
@testable import Networkable

final class DefaultURLRequestFactoryTests: XCTestCase {
    
    var endpoint: SpyEndpoint!
    var baseURL: String!
    var cachePolicy: URLRequest.CachePolicy!
    var timeoutInterval: TimeInterval!
    var sut: DefaultURLRequestFactory!

    override func setUpWithError() throws {
        endpoint = SpyEndpoint()
        endpoint.stubbedHeaders = ["key": "value"]
        endpoint.stubbedPath = #"/path?string=String&int=0&bool=true"#
        endpoint.stubbedMethod = .get
        endpoint.stubbedBodyResult = "data".data(using: .utf8)!
        baseURL = "https://www.apple.com"
        cachePolicy = .useProtocolCachePolicy
        timeoutInterval = 60
        sut = DefaultURLRequestFactory(
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
    
    // MARK: - Init

    func testInit() {
        XCTAssertEqual(sut.baseURL, baseURL)
        XCTAssertEqual(sut.cachePolicy, cachePolicy)
        XCTAssertEqual(sut.timeoutInterval, timeoutInterval)
    }
    
     // MARK: - Make Endpoint
    
    func testMakeEndpoint_whenBaseURLIsInvalid() throws {
        sut.baseURL = " "
        XCTAssertThrowsError(try sut.make(endpoint: endpoint)) { (error: Error) in
            let url = sut.baseURL + endpoint.path
            let expectedError = NetworkableError.invalidURL(url)
            XCTAssertEqual(error as? NetworkableError, expectedError)
        }
    }
    
    func testMakeEndpoint_whenPathIsInvalid() throws {
        endpoint.stubbedPath = " "
        XCTAssertThrowsError(try sut.make(endpoint: endpoint)) { (error: Error) in
            let url = sut.baseURL + endpoint.path
            let expectedError = NetworkableError.invalidURL(url)
            XCTAssertEqual(error as? NetworkableError, expectedError)
        }
    }
    
    func testMakeEndpoint_whenBodyThrowingError() throws {
        let expectedError = DummyError()
        endpoint.stubbedBodyError = expectedError
        XCTAssertThrowsError(try sut.make(endpoint: endpoint)) { (error: Error) in
            XCTAssertEqual(error as? DummyError, expectedError)
        }
    }
    
    func testMakeEndpoint() throws {
        let request = try sut.make(endpoint: endpoint)
        
        XCTAssertTrue(endpoint.invokedHeadersGetter)
        XCTAssertTrue(endpoint.invokedMethodGetter)
        XCTAssertTrue(endpoint.invokedPathGetter)
        XCTAssertTrue(endpoint.invokedMethodGetter)
        XCTAssertTrue(endpoint.invokedBody)
        
        XCTAssertEqual(request.url, URL(string: baseURL + endpoint.stubbedPath))
        XCTAssertEqual(request.cachePolicy, cachePolicy)
        XCTAssertEqual(request.timeoutInterval, timeoutInterval)
        XCTAssertEqual(request.allHTTPHeaderFields, endpoint.stubbedHeaders)
        XCTAssertEqual(request.httpMethod, endpoint.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(request.httpBody, endpoint.stubbedBodyResult)
    }
}

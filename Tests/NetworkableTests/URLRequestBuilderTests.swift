//
//  URLRequestBuilderTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/12/20.
//

import XCTest
@testable import Networkable

final class URLRequestBuilderTests: XCTestCase {
    
    var endpoint: SpyEndpoint!
    var baseURL: URL!
    var cachePolicy: URLRequest.CachePolicy!
    var timeoutInterval: TimeInterval!
    var sut: URLRequestBuilder!

    override func setUpWithError() throws {
        endpoint = SpyEndpoint()
        endpoint.stubbedHeaders = ["key": "value"]
        endpoint.stubbedUrl = #"/path?string=String&int=0&bool=true"#
        endpoint.stubbedMethod = .get
        endpoint.stubbedBodyResult = Data()
        baseURL = URL(string: "https://www.foo.bar")
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
    
    // MARK: - Init

    func testInit() {
        XCTAssertEqual(sut.baseURL, baseURL)
        XCTAssertEqual(sut.cachePolicy, cachePolicy)
        XCTAssertEqual(sut.timeoutInterval, timeoutInterval)
    }
    
     // MARK: - Build Request
    
    func testBuildRequest_whenEndpointURLIsInvalid_itThrowsInvalidURL() throws {
        endpoint.stubbedUrl = ""
        
        XCTAssertThrowsError(try sut.build(endpoint: endpoint)) { (error: Error) in
            XCTAssertEqual(
                error as? NetworkableError,
                .invalidURL(
                    endpoint.stubbedUrl,
                    relativeURL: baseURL))
        }
    }
    
    func testBuildRequest_whenEndpointURLIsAbsolute_soBaseURLTakeNoEffect_inFactBaseURLIsValid_itReturnRequest() throws {
        endpoint.stubbedUrl = "https://www.fizz.buzz/path?string=String&int=0&bool=true"
        let expectedURL = URL(string: endpoint.stubbedUrl)!
        
        XCTAssertNotNil(sut.baseURL)
        XCTAssertFalse(endpoint.stubbedUrl.contains(sut.baseURL!.host!))
        
        let request = try sut.build(endpoint: endpoint)
        
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.cachePolicy, cachePolicy)
        XCTAssertEqual(request.timeoutInterval, timeoutInterval)
        XCTAssertEqual(request.allHTTPHeaderFields, endpoint.stubbedHeaders)
        XCTAssertEqual(request.httpMethod, endpoint.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(request.httpBody, endpoint.stubbedBodyResult)
    }
    
    func testBuildRequest_whenEndpointURLIsAbsolute_soBaseURLTakeNoEffect_inFactBaseURLIsInvalid_itReturnRequest() throws {
        endpoint.stubbedUrl = "https://www.fizz.buzz/path?string=String&int=0&bool=true"
        sut.baseURL = nil
        let expectedURL = URL(string: endpoint.stubbedUrl)!
        
        XCTAssertNil(sut.baseURL)
        
        let request = try sut.build(endpoint: endpoint)
        
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.cachePolicy, cachePolicy)
        XCTAssertEqual(request.timeoutInterval, timeoutInterval)
        XCTAssertEqual(request.allHTTPHeaderFields, endpoint.stubbedHeaders)
        XCTAssertEqual(request.httpMethod, endpoint.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(request.httpBody, endpoint.stubbedBodyResult)
    }
    
    func testBuildRequest_whenEndpointURLIsRelative_andBaseURLIsValid_itReturnRequest() throws {
        endpoint.stubbedUrl = "/path?string=String&int=0&bool=true"
        let expectedURL = URL(string: endpoint.stubbedUrl, relativeTo: baseURL)!.absoluteURL
        
        XCTAssertNotNil(sut.baseURL)
        XCTAssertFalse(endpoint.stubbedUrl.contains(sut.baseURL!.host!))

        let request = try sut.build(endpoint: endpoint)
        
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.cachePolicy, cachePolicy)
        XCTAssertEqual(request.timeoutInterval, timeoutInterval)
        XCTAssertEqual(request.allHTTPHeaderFields, endpoint.stubbedHeaders)
        XCTAssertEqual(request.httpMethod, endpoint.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(request.httpBody, endpoint.stubbedBodyResult)
    }
    
    func testBuildRequest_whenEndpointURLIsRelative_andBaseURLIsInvalid_itReturnRequest() throws {
        endpoint.stubbedUrl = "/path?string=String&int=0&bool=true"
        sut.baseURL = nil
        let expectedURL = URL(string: endpoint.stubbedUrl)!.absoluteURL
        
        XCTAssertNil(sut.baseURL)

        let request = try sut.build(endpoint: endpoint)
        
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.cachePolicy, cachePolicy)
        XCTAssertEqual(request.timeoutInterval, timeoutInterval)
        XCTAssertEqual(request.allHTTPHeaderFields, endpoint.stubbedHeaders)
        XCTAssertEqual(request.httpMethod, endpoint.stubbedMethod.rawValue.uppercased())
        XCTAssertEqual(request.httpBody, endpoint.stubbedBodyResult)
    }
    
    func testBuildRequest_whenEndpointBodyThrowsError_itRethrowsThatError() throws {
        let bodyError = DummyError()
        endpoint.stubbedBodyError = bodyError
        
        XCTAssertThrowsError(try sut.build(endpoint: endpoint)) { (error: Error) in
            XCTAssertEqual(error as? DummyError, bodyError)
        }
    }
}

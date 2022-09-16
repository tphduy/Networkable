//
//  NetworkSessionTests+Async.swift
//  
//
//  Created by Duy Trần on 30/09/2022.
//

import XCTest
@testable import Networkable

@available(iOS 13.0, *)
final class NetworkSessionTests_Async: NetworkSessionTests {
    // MARK: Test Cases - data(for:decoder)
    
    func test_dataWithDecodableResult_whenMiddlewareEncountersErrorAtPrepareRequest() async throws {
        let dummyError = DummyError()
        middleware.stubbedPrepareError = dummyError
        
        do {
            let _ = try await sut.data(for: makeRequest(), decoder: JSONDecoder()) as DummyCodable
            XCTFail("it should encounter an error")
        } catch {
            XCTAssertEqual(error as? DummyError, dummyError)
            XCTAssertTrue(middleware.invokedPrepare)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, urlRequest)
            XCTAssertFalse(middleware.invokedWillSend)
            XCTAssertFalse(middleware.invokedDidReceiveResponse)
            XCTAssertFalse(middleware.invokedDidReceiveError)
        }
    }
    
    func test_dataWithDecodableResult_whenURLSessionEncountersError() async throws {
        let dummyError = DummyError()
        StubbedURLProtocol.stubbedResponseError[urlRequest] = dummyError
        
        do {
            let _ = try await sut.data(for: makeRequest(), decoder: JSONDecoder()) as DummyCodable
            XCTFail("it should encounter an error")
        } catch {
            XCTAssertTrue(middleware.invokedPrepare)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, urlRequest)
            XCTAssertTrue(middleware.invokedWillSend)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, urlRequest)
            XCTAssertFalse(middleware.invokedDidReceiveResponse)
            XCTAssertTrue(middleware.invokedDidReceiveError)
            XCTAssertEqual(middleware.invokedDidReceiveErrorParameters?.request, urlRequest)
        }
    }
    
    func test_dataWithDecodableResult_whenMiddlewareEncountersErrorAtDidReceiveResponse() async throws {
        let dummyError = DummyError()
        middleware.stubbedDidReceiveResponseError = dummyError
        
        do {
            let _ = try await sut.data(for: makeRequest(), decoder: JSONDecoder()) as DummyCodable
            XCTFail("it should encounter an error")
        } catch {
            let spyURLResponse = middleware.invokedDidReceiveResponseParameters?.response as! HTTPURLResponse
            let spyURLResponseHeaders = spyURLResponse.allHeaderFields as! [String: String]
            let urlResponseHeaders = urlResponse.allHeaderFields as! [String: String]
            XCTAssertEqual(error as? DummyError, dummyError)
            XCTAssertTrue(middleware.invokedPrepare)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, urlRequest)
            XCTAssertTrue(middleware.invokedWillSend)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, urlRequest)
            XCTAssertTrue(middleware.invokedDidReceiveResponse)
            XCTAssertEqual(spyURLResponse.url, urlResponse.url)
            XCTAssertEqual(spyURLResponse.statusCode, urlResponse.statusCode)
            XCTAssertEqual(spyURLResponseHeaders, urlResponseHeaders)
            XCTAssertEqual(middleware.invokedDidReceiveResponseParameters?.data, data)
            XCTAssertFalse(middleware.invokedDidReceiveError)
        }
    }
    
    func test_dataWithDecodableResult_whenDecoderEncounterError() async throws {
        do {
            let _ = try await sut.data(for: makeRequest(), decoder: JSONDecoder()) as Int
            XCTFail("it should encounter an error")
        } catch {
            let spyURLResponse = middleware.invokedDidReceiveResponseParameters?.response as! HTTPURLResponse
            let spyURLResponseHeaders = spyURLResponse.allHeaderFields as! [String: String]
            let urlResponseHeaders = urlResponse.allHeaderFields as! [String: String]
            XCTAssertTrue(error is DecodingError)
            XCTAssertTrue(middleware.invokedPrepare)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, urlRequest)
            XCTAssertTrue(middleware.invokedWillSend)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, urlRequest)
            XCTAssertTrue(middleware.invokedDidReceiveResponse)
            XCTAssertEqual(spyURLResponse.url, urlResponse.url)
            XCTAssertEqual(spyURLResponse.statusCode, urlResponse.statusCode)
            XCTAssertEqual(spyURLResponseHeaders, urlResponseHeaders)
            XCTAssertEqual(middleware.invokedDidReceiveResponseParameters?.data, data)
            XCTAssertFalse(middleware.invokedDidReceiveError)
        }
    }
    
    func test_dataWithDecodableResult_withCustomDecoder() async throws {
        struct SnakeCase: Decodable { let fooBar: Int }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        StubbedURLProtocol.stubbedData[urlRequest] = #"{"foo_bar":0}"#.data(using: .utf8)
        
        let result = try await sut.data(for: makeRequest(), decoder: decoder) as SnakeCase
        
        XCTAssertEqual(result.fooBar, 0)
    }
    
    // MARK: Test Cases - data(for:)
    
    func test_data() async throws {
        do {
            try await sut.data(for: makeRequest())
        } catch {
            XCTFail("it should complete without an error")
        }
    }
}

//
//  NetworkSessionTests+Promise.swift
//  
//
//  Created by Duy Trần on 30/09/2022.
//

import XCTest
@testable import Networkable

final class NetworkSessionTests_Promise: NetworkSessionTests {
    // MARK: Test Cases - dataTask(for:resultQueue:decoder:promise)
    
    func test_dataTaskWithDecodableResult_whenMiddlewareEncountersErrorAtPrepareRequest() throws {
        let expectation = expectation(description: "it should encounter an error.")
        let error = DummyError()
        middleware.stubbedPrepareError = error
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder()
        ) { [unowned self] (result: Result<DummyCodable, Error>) in
            guard case let .failure(failure) = result else { return XCTFail(expectation.expectationDescription) }
            XCTAssertEqual(failure as? DummyError, error)
            XCTAssertTrue(middleware.invokedPrepare)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, urlRequest)
            XCTAssertFalse(middleware.invokedWillSend)
            XCTAssertFalse(middleware.invokedDidReceiveResponse)
            XCTAssertFalse(middleware.invokedDidReceiveError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_whenURLSessionEncountersError() throws {
        let expectation = expectation(description: "it should encounter an error.")
        let error = DummyError()
        StubbedURLProtocol.stubbedResponseError[urlRequest] = error
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder()
        ) { [unowned self] (result: Result<DummyCodable, Error>) in
            guard case let .failure(failure) = result else { return XCTFail(expectation.expectationDescription) }
            XCTAssertTrue(middleware.invokedPrepare)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, urlRequest)
            XCTAssertTrue(middleware.invokedWillSend)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, urlRequest)
            XCTAssertFalse(middleware.invokedDidReceiveResponse)
            XCTAssertTrue(middleware.invokedDidReceiveError)
            XCTAssertEqual(middleware.invokedDidReceiveErrorParameters?.error.localizedDescription, failure.localizedDescription)
            XCTAssertEqual(middleware.invokedDidReceiveErrorParameters?.request, urlRequest)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_whenMiddlewareEncountersErrorAtDidReceiveResponse() throws {
        let expectation = expectation(description: "it should encounter an error.")
        let error = DummyError()
        middleware.stubbedDidReceiveResponseError = error
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder()
        ) { [unowned self] (result: Result<DummyCodable, Error>) in
            guard case let .failure(failure) = result else { return XCTFail(expectation.expectationDescription) }
            let spyURLResponse = middleware.invokedDidReceiveResponseParameters?.response as! HTTPURLResponse
            let spyURLResponseHeaders = spyURLResponse.allHeaderFields as! [String: String]
            let urlResponseHeaders = urlResponse.allHeaderFields as! [String: String]
            XCTAssertEqual(failure as? DummyError, error)
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
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_whenDecoderEncounterError() throws {
        let expectation = expectation(description: "it should encounter an error.")
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder()
        ) { [unowned self] (result: Result<Int, Error>) in
            guard case let .failure(failure) = result else { return XCTFail(expectation.expectationDescription) }
            let spyURLResponse = middleware.invokedDidReceiveResponseParameters?.response as! HTTPURLResponse
            let spyURLResponseHeaders = spyURLResponse.allHeaderFields as! [String: String]
            let urlResponseHeaders = urlResponse.allHeaderFields as! [String: String]
            XCTAssertTrue(failure is DecodingError)
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
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_withoutResultQueue() throws {
        let expectation = expectation(description: "it should dispatch the promise on the default queue.")
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: nil,
            decoder: JSONDecoder()
        ) { (result: Result<DummyCodable, Error>) in
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_withResultQueue() throws {
        let expectation = expectation(description: "it should dispatch the promise on the main queue.")
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder()
        ) { (result: Result<DummyCodable, Error>) in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_withCustomDecoder() throws {
        struct SnakeCase: Decodable { let fooBar: Int }
        
        let expectation = expectation(description: "it should decode data successfully.")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        StubbedURLProtocol.stubbedData[urlRequest] = #"{"foo_bar":0}"#.data(using: .utf8)
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: .main,
            decoder: decoder
        ) { (result: Result<SnakeCase, Error>) in
            guard case let .success(success) = result else { return XCTFail(expectation.expectationDescription) }
            XCTAssertEqual(success.fooBar, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    // MARK: Test Cases - dataTask(for:resultQueue:promise:)
    
    func test_dataTask_withoutResultQueue() throws {
        let expectation = expectation(description: "it should dispatch the promise on the default queue.")
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: nil
        ) { (result: Result<Void, Error>) in
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTask_withResultQueue() throws {
        let expectation = expectation(description: "it should dispatch the promise on the main queue.")
        
        sut.dataTask(
            for: makeRequest(),
            resultQueue: .main
        ) { (result: Result<Void, Error>) in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}

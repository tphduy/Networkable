//
//  DefaultWebRepositoryTests+Promise.swift
//  NetworkableTests
//
//  Created by Duy Tran on 16/04/2022.
//

import XCTest
@testable import Networkable

final class DefaultWebRepositoryTests_Promise: DefaultWebRepositoryTests {
    // MARK: Test Cases - call(to:resultQueue:decoder:promise:)
    
    func test_call_whenPreparing_andThrowingMiddlewareError() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error as DummyError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        sut.call(to: endpoint) { (result: Result<Void, Error>) in
            guard case let .failure(error as DummyError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 2)
        XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
        XCTAssertFalse(middleware.invokedWillSend)
        XCTAssertFalse(middleware.invokedDidReceive)
    }
     
    func test_call_whenCompleted_andThrowingNetworkingError() throws {
        session.set(stubbedResponseError: DummyError(), for: request)
        
        let message = "expect throwing \(NSError.self)"
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case .failure = result else { return XCTFail(message) }
            expectation.fulfill()
        }
        
        sut.call(to: endpoint) { (result: Result<Void, Error>) in
            guard case .failure = result else { return XCTFail(message) }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 2)
        XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedWillSendCount, 2)
        XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
        XCTAssertFalse(middleware.invokedDidReceive)
    }
    
    func test_call_whenCompleted_andThrowingDecodingError() throws {
        data = "invalid JSON".data(using: .utf8)
        session.set(stubbedData: data, for: request)
        
        let message = "expect throwing \(DecodingError.self)"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error) = result else { return XCTFail(message) }
            XCTAssertTrue(error is DecodingError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 1)
        XCTAssertEqual(middleware.invokedPrepareParameters?.request, request)
        XCTAssertEqual(middleware.invokedWillSendCount, 1)
        XCTAssertEqual(middleware.invokedWillSendParameters?.request, request)
        XCTAssertEqual(middleware.invokedDidReceiveCount, 1)
        XCTAssertEqual(middleware.invokedDidReceiveParameters?.response.url, response.url)
        XCTAssertEqual(middleware.invokedDidReceiveParameters?.data, data)
    }
    
    func test_call_whenCompleted_andThrowingMiddlewareError() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveError = expected
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error as DummyError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        sut.call(to: endpoint) { (result: Result<Void, Error>) in
            guard case let .failure(error as DummyError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 2)
        XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedWillSendCount, 2)
        XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedDidReceiveCount, 2)
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.response.url }), [response.url, response.url])
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.data }), [data, data])
    }
    
    func test_call_whenCompleted_withNoResponse() throws {
        let expected = NetworkableError.empty
        session.set(stubbedResponse: nil, for: request)
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error as NetworkableError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        sut.call(to: endpoint) { (result: Result<Void, Error>) in
            guard case let .failure(error as NetworkableError) = result else { return XCTFail(message) }
            XCTAssertEqual(error, expected)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 2)
        XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedWillSendCount, 2)
        XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
        XCTAssertFalse(middleware.invokedDidReceive)
    }
    
    func test_call_whenCompleted_withNoData() throws {
        session.set(stubbedData: nil, for: request)
        
        let message = "expect throwing \(DecodingError.self)"
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case let .failure(error) = result else { return XCTFail(message) }
            XCTAssertTrue(error is DecodingError)
            expectation.fulfill()
        }
        
        sut.call(to: endpoint) { (result: Result<Void, Error>) in
            guard case .success = result else { return XCTFail(message) }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 2)
        XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedWillSendCount, 2)
        XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedDidReceiveCount, 2)
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.response.url }), [response.url, response.url])
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.data }), [Data(), Data()])
    }
    
    func test_call_whenCompleted() throws {
        let message = "expect throwing no error"
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            guard case .success = result else { return XCTFail(message) }
            expectation.fulfill()
        }
        
        sut.call(to: endpoint) { (result: Result<Void, Error>) in
            guard case .success = result else { return XCTFail(message) }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 2)
        XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedWillSendCount, 2)
        XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedDidReceiveCount, 2)
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.response.url }), [response.url, response.url])
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.data }), [data, data])
    }
    
    func test_call_whenCompleted_onGlobalQueue() {
        let message = "expect promise is executed on global background thread."
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint, resultQueue: .global(qos: .background)) { (result: Result<DummyCodable, Error>) in
            XCTAssertTrue(Thread.current.qualityOfService == .background)
            expectation.fulfill()
        }
        
        sut.call(to: endpoint, resultQueue: .global(qos: .background)) { (result: Result<Void, Error>) in
            XCTAssertTrue(Thread.current.qualityOfService == .background)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}

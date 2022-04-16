//
//  DefaultWebRepositoryTests+Publisher.swift
//  NetworkableTests
//
//  Created by Duy Tran on 15/04/2022.
//

#if canImport(Combine)
import Combine
import XCTest
@testable import Networkable

@available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
final class DefaultWebRepositoryTests_Combine: DefaultWebRepositoryTests {
    // MARK: Misc
    
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: Life Cycle
    
    override func setUpWithError() throws {
        cancellables = Set()
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        try super.tearDownWithError()
    }
    
    // MARK: Test Cases - call(to:decoder:resultType:)
    
    func test_call_whenPreparing_andMiddlewareThrowError() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error as DummyError) = completion else { return XCTFail(message) }
                XCTAssertEqual(error, expected)
                expectation.fulfill()
            }, receiveValue: { (_: DummyCodable) in
                XCTFail(message)
            })
            .store(in: &cancellables)
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error as DummyError) = completion else { return XCTFail(message) }
                XCTAssertEqual(error, expected)
                expectation.fulfill()
            }, receiveValue: { (_: Void) in
                XCTFail(message)
            })
            .store(in: &cancellables)
        
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
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case .failure = completion else { return XCTFail(message) }
                expectation.fulfill()
            }, receiveValue: { (_: DummyCodable) in
                XCTFail(message)
            })
            .store(in: &cancellables)
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case .failure = completion else { return XCTFail(message) }
                expectation.fulfill()
            }, receiveValue: { (_: Void) in
                XCTFail(message)
            })
            .store(in: &cancellables)
        
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
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error) = completion else { return XCTFail(message) }
                XCTAssertTrue(error is DecodingError)
                expectation.fulfill()
            }, receiveValue: { (_: DummyCodable) in
                XCTFail(message)
            })
            .store(in: &cancellables)
        
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
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error as DummyError) = completion else { return XCTFail(message) }
                XCTAssertEqual(error, expected)
                expectation.fulfill()
            }, receiveValue: { (_: DummyCodable) in
                XCTFail(message)
            })
            .store(in: &cancellables)
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error as DummyError) = completion else { return XCTFail(message) }
                XCTAssertEqual(error, expected)
                expectation.fulfill()
            }, receiveValue: { (_: Void) in
                XCTFail(message)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 2)
        XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedWillSendCount, 2)
        XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedDidReceiveCount, 2)
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.response.url }), [response.url, response.url])
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.data }), [data, data])
    }
    
    func test_call_whenCompleted() throws {
        let message = "expect throwing no error"
        let expectation = self.expectation(description: message)
        expectation.expectedFulfillmentCount = 2
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case .failure = completion else { return }
                XCTFail(message)
            }, receiveValue: { (_: DummyCodable) in
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case .failure = completion else { return }
                XCTFail(message)
            }, receiveValue: { (_: Void) in
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(middleware.invokedPrepareCount, 2)
        XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedWillSendCount, 2)
        XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
        XCTAssertEqual(middleware.invokedDidReceiveCount, 2)
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.response.url }), [response.url, response.url])
        XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.data }), [data, data])
    }
}
#endif

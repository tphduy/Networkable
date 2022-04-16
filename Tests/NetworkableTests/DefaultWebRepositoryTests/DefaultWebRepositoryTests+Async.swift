//
//  DefaultWebRepositoryTests+Async.swift
//  NetworkableTests
//
//  Created by Duy Tran on 16/04/2022.
//

import XCTest
@testable import Networkable

@available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
final class DefaultWebRepositoryTests_Async: DefaultWebRepositoryTests {
    // MARK: Test Cases - call(to:decoder:resultType)
    
    func test_call_whenPreparing_andThrowingMiddlewareError() async throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        
        do {
            let _ = try await sut.call(to: endpoint, resultType: DummyCodable.self)
        } catch {
            XCTAssertEqual(middleware.invokedPrepareCount, 1)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, request)
            XCTAssertFalse(middleware.invokedWillSend)
            XCTAssertFalse(middleware.invokedDidReceive)
            XCTAssertEqual(error as! DummyError, expected)
        }
        
        do {
            try await sut.call(to: endpoint)
        } catch {
            XCTAssertEqual(error as! DummyError, expected)
            XCTAssertEqual(middleware.invokedPrepareCount, 2)
            XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
            XCTAssertFalse(middleware.invokedWillSend)
            XCTAssertFalse(middleware.invokedDidReceive)
        }
    }
    
    func test_call_whenCompleted_andThrowingNetworkingError() async throws {
        session.set(stubbedResponseError: DummyError(), for: request)
        
        do {
            let _ = try await sut.call(to: endpoint, resultType: DummyCodable.self)
        } catch {
            XCTAssertTrue(true)
            XCTAssertEqual(middleware.invokedPrepareCount, 1)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, request)
            XCTAssertEqual(middleware.invokedWillSendCount, 1)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, request)
            XCTAssertFalse(middleware.invokedDidReceive)
        }
        
        do {
            try await sut.call(to: endpoint)
        } catch {
            XCTAssertTrue(true)
            XCTAssertEqual(middleware.invokedPrepareCount, 2)
            XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
            XCTAssertEqual(middleware.invokedWillSendCount, 2)
            XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
            XCTAssertFalse(middleware.invokedDidReceive)
        }
    }
    
    func test_call_whenCompleted_andThrowingDecodingError() async throws {
        data = "invalid JSON".data(using: .utf8)
        session.set(stubbedData: data, for: request)
        
        do {
            let _ = try await sut.call(to: endpoint, resultType: DummyCodable.self)
        } catch {
            XCTAssertTrue(error is DecodingError)
            XCTAssertEqual(middleware.invokedPrepareCount, 1)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, request)
            XCTAssertEqual(middleware.invokedWillSendCount, 1)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, request)
            XCTAssertEqual(middleware.invokedDidReceiveCount, 1)
            XCTAssertEqual(middleware.invokedDidReceiveParameters?.response.url, response.url)
            XCTAssertEqual(middleware.invokedDidReceiveParameters?.data, data)
        }
        
        do {
            try await sut.call(to: endpoint)
        } catch {
            XCTFail("expected not throwing")
        }
    }
    
    func test_call_whenCompleted_andThrowingMiddlewareError() async throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveError = expected
        
        do {
            let _ = try await sut.call(to: endpoint, resultType: DummyCodable.self)
        } catch {
            XCTAssertEqual(error as! DummyError, expected)
            XCTAssertEqual(middleware.invokedPrepareCount, 1)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, request)
            XCTAssertEqual(middleware.invokedWillSendCount, 1)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, request)
            XCTAssertEqual(middleware.invokedDidReceiveCount, 1)
            XCTAssertEqual(middleware.invokedDidReceiveParameters?.response.url, response.url)
            XCTAssertEqual(middleware.invokedDidReceiveParameters?.data, data)
        }
        
        do {
            try await sut.call(to: endpoint)
        } catch {
            XCTAssertEqual(error as! DummyError, expected)
            XCTAssertEqual(middleware.invokedPrepareCount, 2)
            XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
            XCTAssertEqual(middleware.invokedWillSendCount, 2)
            XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
            XCTAssertEqual(middleware.invokedDidReceiveCount, 2)
            XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.response.url }), [response.url, response.url])
            XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.data }), [data, data])
        }
    }
    
    func test_call_whenCompleted() async throws {
        do {
            let _ = try await sut.call(to: endpoint, resultType: DummyCodable.self)
            XCTAssertEqual(middleware.invokedPrepareCount, 1)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, request)
            XCTAssertEqual(middleware.invokedWillSendCount, 1)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, request)
            XCTAssertEqual(middleware.invokedDidReceiveCount, 1)
            XCTAssertEqual(middleware.invokedDidReceiveParameters?.response.url, response.url)
            XCTAssertEqual(middleware.invokedDidReceiveParameters?.data, data)
        } catch {
            XCTFail("expected not throwing")
        }
        
        do {
            try await sut.call(to: endpoint)
            XCTAssertEqual(middleware.invokedPrepareCount, 2)
            XCTAssertEqual(middleware.invokedPrepareParametersList.map({ $0.request }), [request, request])
            XCTAssertEqual(middleware.invokedWillSendCount, 2)
            XCTAssertEqual(middleware.invokedWillSendParametersList.map({ $0.request }), [request, request])
            XCTAssertEqual(middleware.invokedDidReceiveCount, 2)
            XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.response.url }), [response.url, response.url])
            XCTAssertEqual(middleware.invokedDidReceiveParametersList.map({ $0.data }), [data, data])
        } catch {
            XCTFail("expected not throwing")
        }
    }
}

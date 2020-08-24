//
//  DefaultRepositoryTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import Combine
import XCTest
@testable import Networking

@available(iOS 13.0, OSX 10.15, *)
final class DefaultRepositoryTests: XCTestCase {
    var endpoint: SpyEndpoint!
    var codes: HTTPCodes!
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var data: Data!
    var resultQueue: DispatchQueue!
    var decoder: JSONDecoder!
    var cancellable: Set<AnyCancellable>!
    var requestFactory: SpyURLRequestFactory!
    var middleware: SpyMiddleware!
    var session: URLSession!
    var executionQueue: DispatchQueue!

    var sut: DefaultRepository!

    override func setUpWithError() throws {
        endpoint = SpyEndpoint()
        codes = .success
        url = URL(string: "https://www.apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        data = #"{ "lorem": "isplum" }"#.data(using: .utf8)
        resultQueue = .main
        decoder = JSONDecoder()
        cancellable = Set<AnyCancellable>()
        requestFactory = SpyURLRequestFactory()
        requestFactory.stubbedMakeResult = request
        middleware = SpyMiddleware()
        middleware.stubbedPrepareResult = request
        session = .stubbed
        executionQueue = .global()

        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)

        sut = DefaultRepository(
            requestFactory: requestFactory,
            middlewares: [middleware],
            session: session)
    }

    override func tearDownWithError() throws {
        session.tearDown()
        endpoint = nil
        codes = nil
        url = nil
        request = nil
        response = nil
        data = nil
        resultQueue = nil
        decoder = nil
        cancellable = nil
        requestFactory = nil
        session = nil
        executionQueue = nil

        sut = nil
    }

    func testInit() {
        XCTAssertTrue(sut.requestFactory as? SpyURLRequestFactory === requestFactory)
        XCTAssertTrue(sut.middlewares as! [SpyMiddleware] == [middleware])
        XCTAssertEqual(sut.session, session)
    }

    // MARK: - Threading

    func testCallThreading() throws {
        let expectation = self.expectation(description: "expected running on main thread")
        
        sut.call(to: endpoint, resulttQueue: .main)
            .sink(receiveCompletion: { (_) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }, receiveValue: { (data: String) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            })
            .store(in: &cancellable)

        wait(for: [expectation], timeout: 0.5)
    }
    
    func testCallWithPromiseThreading() {
        let expectation = self.expectation(description: "expected running on main thread")
        
        sut.call(to: endpoint, resulttQueue: .main) { (result: Result<Dictionary<String, String>, Error>) in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }

    // MARK: - Request Factory
    
    func testCallWhenRequestFactoryThrowError() throws {
        let expected = DummyError()
        requestFactory.stubbedMakeError = expected
        call(throwingError: expected)
    }
    
    func testCallWithPromiseWhenRequestFactoryThrowError() throws {
        let expected = DummyError()
        requestFactory.stubbedMakeError = expected
        callWithPromise(throwingError: expected)
    }

    // MARK: - Middleware
    
    func testCallInvokeMiddleware() throws {
        let prepareRequestExpectation = self.expectation(description: "expected invoking middleware for preparing request")
        let willSendRequestExpectation = self.expectation(description: "expected invoking middleware for will-send-request event")
        let didReceiveResponseExpectation = self.expectation(description: "expected invoking middeware for did-receive-response event")
        let didReceiveDataExpectation = self.expectation(description: "expected invoking middeware for did-receive-data event")

        sut.call(
            to: endpoint,
            acceptedInRange: codes,
            resulttQueue: resultQueue)
            .sink(receiveCompletion: { (_: Subscribers.Completion<Error>) in
            }, receiveValue: { (_: Dictionary<String, String>) in
                XCTAssertTrue(self.middleware.invokedPrepare)
                XCTAssertTrue(self.middleware.invokedWillSend)
                XCTAssertTrue(self.middleware.invokedDidReceive)

                prepareRequestExpectation.fulfill()
                willSendRequestExpectation.fulfill()
                didReceiveResponseExpectation.fulfill()
                didReceiveDataExpectation.fulfill()
            })
            .store(in: &cancellable)

        wait(
            for: [
                prepareRequestExpectation,
                willSendRequestExpectation,
                didReceiveResponseExpectation,
                didReceiveDataExpectation
        ], timeout: 0.5)
    }

    func testCallFailedWhenMiddlewareThrowErrorInPrepareRequest() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        call(throwingError: expected)
    }

    func testCallFailedWhenMiddlewareThrowErrorInDidReceiveResponseData() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveError = expected
        call(throwingError: expected)
    }
    
    func testCallWithPromiseInvokeMiddleware() throws {
        let prepareRequestExpectation = self.expectation(description: "expected invoking middleware for preparing request")
        let willSendRequestExpectation = self.expectation(description: "expected invoking middleware for will-send-request event")
        let didReceiveResponseExpectation = self.expectation(description: "expected invoking middeware for did-receive-response event")
        
        sut.call(to: endpoint) { (result: Result<Dictionary<String, String>, Error>) in
            XCTAssertTrue(self.middleware.invokedPrepare)
            XCTAssertTrue(self.middleware.invokedWillSend)
            XCTAssertTrue(self.middleware.invokedDidReceive)
            
            prepareRequestExpectation.fulfill()
            willSendRequestExpectation.fulfill()
            didReceiveResponseExpectation.fulfill()
        }

        wait(
            for: [
                prepareRequestExpectation,
                willSendRequestExpectation,
                didReceiveResponseExpectation,
            ],
            timeout: 0.5)
    }
    
    func testCallWithPromiseFailedWhenMiddlewareThrowErrorInPrepareRequest() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        callWithPromise(throwingError: expected)
    }
    
    func testCallWithPromiseFailedWhenMiddlewareThrowErrorInDidReceiveResponseData() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveError = expected
        callWithPromise(throwingError: expected)
    }
}

@available(iOS 13.0, OSX 10.15, *)
extension DefaultRepositoryTests {
    
    private func call(throwingError expected: DummyError) {
        let expectation = self.expectation(description: "expected throwing \(expected)")

        sut.call(
            to: endpoint,
            acceptedInRange: codes,
            resulttQueue: resultQueue)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error) = completion else {
                    XCTFail(expectation.expectationDescription)
                    return
                }
                XCTAssertEqual(error as? DummyError, expected)
                expectation.fulfill()
            }, receiveValue: { (_: [String]) in
                XCTFail(expectation.expectationDescription)
            })
            .store(in: &cancellable)

        wait(for: [expectation], timeout: 0.5)
    }
    
    private func callWithPromise(throwingError expected: DummyError) {
        let expectation = self.expectation(description: "expected throwing \(expected)")
        
        sut.call(
            to: endpoint,
            acceptedInRange: codes,
            resulttQueue: .main) { (result: Result<Dictionary<String, String>, Error>) in
                switch result {
                case let .failure(error):
                    XCTAssertEqual(error as? DummyError, expected)
                    expectation.fulfill()
                case .success:
                    XCTFail(expectation.expectationDescription)
                }
            }
        
        wait(for: [expectation], timeout: 0.5)
    }
}

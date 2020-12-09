//
//  DefaultRepositoryTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

#if canImport(Combine)
import Combine
#endif
import XCTest
@testable import Networkable

final class DefaultRepositoryTests: XCTestCase {
    var endpoint: SpyEndpoint!
    var codes: ResponseStatusCodes!
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var data: Data!
    var executionQueue: DispatchQueue!
    var resultQueue: DispatchQueue!
    var decoder: JSONDecoder!
    var requestFactory: SpyURLRequestFactory!
    var middleware: SpyMiddleware!
    var session: URLSession!

    var sut: DefaultRepository!

    override func setUpWithError() throws {
        endpoint = SpyEndpoint()
        codes = .success
        url = URL(string: "https://www.apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        data = #"{ "lorem": "isplum" }"#.data(using: .utf8)
        resultQueue = .main
        executionQueue = .global()
        decoder = JSONDecoder()
        requestFactory = SpyURLRequestFactory()
        requestFactory.stubbedMakeResult = request
        middleware = SpyMiddleware()
        middleware.stubbedPrepareResult = request
        session = .stubbed

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
        executionQueue = nil
        decoder = nil
        requestFactory = nil
        session = nil
        sut = nil
    }

    func testInit() {
        XCTAssertTrue(sut.requestFactory as? SpyURLRequestFactory === requestFactory)
        XCTAssertTrue(sut.middlewares as! [SpyMiddleware] == [middleware])
        XCTAssertEqual(sut.session, session)
    }

    // MARK: - Threading
    
    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func testCallThreading() throws {
        var cancellable = Set<AnyCancellable>()
        let expectation = self.expectation(description: "expected running on main thread")
        
        sut.call(to: endpoint, resultQueue: .main)
            .sink(receiveCompletion: { (_) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }, receiveValue: { (_: String) in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: 0.5)
    }
    #endif

    func testCallWithPromiseThreading() {
        let expectation = self.expectation(description: "expected running on main thread")

        sut.call(to: endpoint, resultQueue: .main) { (_: Result<[String: String], Error>) in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.5)
    }

    // MARK: - Request Factory
    
    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func testCallWhenRequestFactoryThrowError() throws {
        let expected = DummyError()
        requestFactory.stubbedMakeError = expected
        call(throwingError: expected)
    }
    #endif

    func testCallWithPromiseWhenRequestFactoryThrowError() throws {
        let expected = DummyError()
        requestFactory.stubbedMakeError = expected
        callWithPromise(throwingError: expected)
    }

    // MARK: - Middleware
    
    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func testCallInvokeMiddleware() throws {
        var cancellable = Set<AnyCancellable>()
        let prepareRequestExpectation = self.expectation(description: "expected invoking middleware for preparing request")
        let willSendRequestExpectation = self.expectation(description: "expected invoking middleware for will-send-request event")
        let didReceiveResponseExpectation = self.expectation(description: "expected invoking middeware for did-receive-response event")
        let didReceiveDataExpectation = self.expectation(description: "expected invoking middeware for did-receive-data event")

        sut.call(to: endpoint)
            .sink(receiveCompletion: { (_: Subscribers.Completion<Error>) in
            }, receiveValue: { (_: [String: String]) in
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

    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func testCallFailedWhenMiddlewareThrowErrorInPrepareRequest() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        call(throwingError: expected)
    }

    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func testCallFailedWhenMiddlewareThrowErrorInDidReceiveResponseData() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveError = expected
        call(throwingError: expected)
    }
    #endif

    func testCallWithPromiseInvokeMiddleware() throws {
        let prepareRequestExpectation = self.expectation(description: "expected invoking middleware for preparing request")
        let willSendRequestExpectation = self.expectation(description: "expected invoking middleware for will-send-request event")
        let didReceiveResponseExpectation = self.expectation(description: "expected invoking middeware for did-receive-response event")

        sut.call(to: endpoint) { (_: Result<[String: String], Error>) in
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
                didReceiveResponseExpectation
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

    // MARK: - Response

    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func testCallThrowErrorWhenRecievingError() {
        let error = DummyError()
        let request = requestFactory.stubbedMakeResult!
        session.set(stubbedResponseError: error, for: request)
        call(throwingError: error)
    }
    #endif
    
    func testCallWithPromiseThrowErrorWhenRecievingError() {
        let error = DummyError()
        let request = requestFactory.stubbedMakeResult!
        session.set(stubbedResponseError: error, for: request)
        callWithPromise(throwingError: error)
    }

    func testCallWithPromiseThrowEmptyWhenResponseIsNil() {
        let error = NetworkableError.empty
        let request = requestFactory.stubbedMakeResult!
        session.set(stubbedResponse: nil, for: request)
        callWithPromise(throwingError: error)
    }
}

extension DefaultRepositoryTests {

    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    private func call<E: Error & Equatable>(throwingError expected: E) {
        var cancellable = Set<AnyCancellable>()
        let expectation = self.expectation(description: "expected throwing \(expected)")

        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .failure:
                    expectation.fulfill()
                case .finished:
                    XCTFail(expectation.expectationDescription)
                }
            }, receiveValue: { (_: [String]) in
                XCTFail(expectation.expectationDescription)
            })
            .store(in: &cancellable)

        wait(for: [expectation], timeout: 0.5)
    }
    #endif
    
    private func callWithPromise<E: Error & Equatable>(throwingError expected: E) {
        let expectation = self.expectation(description: "expected throwing \(expected)")

        sut.call(to: endpoint) { (result: Result<[String: String], Error>) in
            switch result {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail(expectation.expectationDescription)
            }
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
}

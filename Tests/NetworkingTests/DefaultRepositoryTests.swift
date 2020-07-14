//
//  DefaultRepositoryTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

#if canImport(Combine)
import Combine
import XCTest
@testable import Networking

@available(OSX 10.15, *)
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
        data = "[\"lorem\"]".data(using: .utf8)
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
            session: session,
            executionQueue: executionQueue)
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
        XCTAssertEqual(sut.session, session)
        XCTAssertEqual(sut.executionQueue, executionQueue)
    }

    // MARK: - Threading

    func testCallDataThreading() throws {
        let resultExpectation = self.expectation(description: "expected running on main thread")

        sut.call(
            to: endpoint,
            acceptedInRange: codes,
            resulttQueue: .main)
            .sink(receiveCompletion: { (_) in
            }, receiveValue: { (_: Data) in
                XCTAssertTrue(Thread.isMainThread)
                resultExpectation.fulfill()
            })
            .store(in: &cancellable)

        wait(for: [resultExpectation], timeout: 0.5)
    }

    func testCallDecodableThreading() throws {
        let resultExpectation = self.expectation(description: "expected running on main thread")

        sut.call(
            to: endpoint,
            acceptedInRange: codes,
            resulttQueue: .main)
            .sink(receiveCompletion: { (_) in
            }, receiveValue: { (_: [String]) in
                XCTAssertTrue(Thread.isMainThread)
                resultExpectation.fulfill()
            })
            .store(in: &cancellable)

        wait(for: [resultExpectation], timeout: 0.5)
    }

    // MARK: - Request Factory

    func testCallDataWhenRequestFactoryThrowError() throws {
        let expected = DummyError()
        requestFactory.stubbedMakeError = expected
        callData(throwingError: expected)
    }

    func testCallDecodableWhenRequestFactoryThrowError() throws {
        let expected = DummyError()
        requestFactory.stubbedMakeError = expected

        callDecodable(throwingError: expected)
    }

    // MARK: - Middleware

    func testCallDataInvokeMiddleware() throws {
        let prepareRequestExpectation = self.expectation(description: "expected invoking middleware for preparing request")
        let willSendRequestExpectation = self.expectation(description: "expected invoking middleware for will-send-request event")
        let didReceiveResponseExpectation = self.expectation(description: "expected invoking middeware for did-receive-response event")
        let didReceiveDataExpectation = self.expectation(description: "expected invoking middeware for did-receive-data event")

        sut.call(
            to: endpoint,
            acceptedInRange: codes,
            resulttQueue: resultQueue)
            .sink(receiveCompletion: { (_: Subscribers.Completion<Error>) in
            }, receiveValue: { (_: Data) in
                XCTAssertTrue(self.middleware.invokedPrepare)
                XCTAssertTrue(self.middleware.invokedWillSend)
                XCTAssertTrue(self.middleware.invokedDidReceiveResponse)
                XCTAssertTrue(self.middleware.invokedDidReceiveData)

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

    func testCallDataFailedWhenMiddlewareThrowErrorInPrepareRequest() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        callData(throwingError: expected)
    }

    func testCallDataFailedWhenMiddlewareThrowErrorInDidReceiveResponse() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveResponseError = expected
        callData(throwingError: expected)
    }

    func testCallDataFailedWhenMiddlewareThrowErrorInDidReceiveData() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveDataError = expected
        callData(throwingError: expected)
    }

    func testCallDecodableInvokeMiddleware() throws {
        let prepareRequestExpectation = self.expectation(description: "expected invoking middleware for preparing request")
        let willSendRequestExpectation = self.expectation(description: "expected invoking middleware for will-send-request event")
        let didReceiveResponseExpectation = self.expectation(description: "expected invoking middeware for did-receive-response event")
        let didReceiveDataExpectation = self.expectation(description: "expected invoking middeware for did-receive-data event")

        sut.call(
            to: endpoint,
            acceptedInRange: codes,
            resulttQueue: resultQueue)
            .sink(receiveCompletion: { (_: Subscribers.Completion<Error>) in
            }, receiveValue: { (_: [String]) in
                XCTAssertTrue(self.middleware.invokedPrepare)
                XCTAssertTrue(self.middleware.invokedWillSend)
                XCTAssertTrue(self.middleware.invokedDidReceiveResponse)
                XCTAssertTrue(self.middleware.invokedDidReceiveData)

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

    func testCallDecodableFailedWhenMiddlewareThrowErrorInPrepareRequest() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        callDecodable(throwingError: expected)
    }

    func testCallDecodableFailedWhenMiddlewareThrowErrorInDidReceiveResponse() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveResponseError = expected
        callDecodable(throwingError: expected)
    }

    func testCallDecodableFailedWhenMiddlewareThrowErrorInDidReceiveData() throws {
        let expected = DummyError()
        middleware.stubbedDidReceiveDataError = expected
        callDecodable(throwingError: expected)
    }
}

@available(OSX 10.15, *)
extension DefaultRepositoryTests {
    private func callData(throwingError expected: DummyError) {
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
            }, receiveValue: { (_: Data) in
                XCTFail(expectation.expectationDescription)
            })
            .store(in: &cancellable)

        wait(for: [expectation], timeout: 0.5)
    }

    private func callDecodable(throwingError expected: DummyError) {
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
}

#endif

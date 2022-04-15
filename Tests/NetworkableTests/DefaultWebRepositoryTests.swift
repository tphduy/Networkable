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

class DefaultWebRepositoryTests: XCTestCase {
    
    var data: Data!
    var url: String!
    var method: Networkable.Method!
    var headers: [String: String]!
    var body: Data!
    var request: URLRequest!
    var response: HTTPURLResponse!
    var endpoint: SpyEndpoint!
    var requestBuilder: SpyURLRequestBuildable!
    var middleware: SpyMiddleware!
    var session: URLSession!
    var sut: DefaultWebRepository!
    
    override func setUpWithError() throws {
        data = "{}".data(using: .utf8)
        url = "https://www.foo.bar"
        method = .get
        headers = ["Foo": "Bar"]
        body = data
        request = URLRequest(url: URL(string: url)!)
        response = HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)
        
        endpoint = SpyEndpoint()
        endpoint.stubbedUrl = url
        endpoint.stubbedMethod = method
        endpoint.stubbedHeaders = headers
        endpoint.stubbedBodyResult = Data()
        requestBuilder = SpyURLRequestBuildable()
        requestBuilder.stubbedMakeResult = request
        middleware = SpyMiddleware()
        middleware.stubbedPrepareResult = request
        session = .stubbed
        sut = DefaultWebRepository(
            requestBuilder: requestBuilder,
            middlewares: [middleware],
            session: session)
    }
    
    override func tearDownWithError() throws {
        session.tearDown()
        data = nil
        url = nil
        method = nil
        headers = nil
        body = nil
        request = nil
        response = nil
        endpoint = nil
        requestBuilder = nil
        middleware = nil
        session = nil
        sut = nil
    }
    
    // MARK: - Init
    
    func testInit() throws {
        XCTAssertTrue(sut.requestBuilder as? SpyURLRequestBuildable === requestBuilder)
        XCTAssertTrue(sut.middlewares.first as? SpyMiddleware === middleware)
        XCTAssertEqual(sut.middlewares.count, 1)
        XCTAssertEqual(sut.session, session)
    }
    
    // MARK: - Make Request
    
    func testMakeRequest_whenRequestBuilderThrowsError_itRethrowsThatError() throws {
        let dummyError = DummyError()
        requestBuilder.stubbedMakeError = dummyError
        
        XCTAssertThrowsError(
            try sut.makeRequest(
                endpoint: endpoint,
                middlewares: [middleware])) { (error: Error) in
            XCTAssertEqual(error as? DummyError, dummyError)
        }
        XCTAssertTrue(requestBuilder.invokedMake)
    }
    
    func testMakeRequest_whenMiddlewareThrowsError_itRethrowsThatError() throws {
        let dummyError = DummyError()
        middleware.stubbedPrepareError = dummyError
        
        XCTAssertThrowsError(
            try sut.makeRequest(
                endpoint: endpoint,
                middlewares: [middleware])) { (error: Error) in
            XCTAssertEqual(error as? DummyError, dummyError)
        }
        
        XCTAssertTrue(middleware.invokedPrepare)
    }
    
    func testMakeRequest_whenMiddlewaresIsEmpty_itReturnRequestConstructedRequestBuilder() throws {
        let preparedRequest = try sut.makeRequest(
            endpoint: endpoint,
            middlewares: [])
        
        XCTAssertEqual(preparedRequest, requestBuilder.stubbedMakeResult)
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertFalse(middleware.invokedPrepare)
    }
    
    func testMakeRequest_whenMiddlewaresAreSome_itReturnLastModifiedRequestMadeByMiddleware() throws {
        let otherMiddleware = SpyMiddleware()
        otherMiddleware.stubbedPrepareResult = URLRequest(url: URL(string: "https://www.apple.com")!)
        
        XCTAssertNotEqual(middleware.stubbedPrepareResult, otherMiddleware.stubbedPrepareResult)
        
        let preparedRequest = try sut.makeRequest(
            endpoint: endpoint,
            middlewares: [middleware, otherMiddleware])
        
        XCTAssertEqual(preparedRequest, otherMiddleware.stubbedPrepareResult)
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(otherMiddleware.invokedPrepare)
    }
    
    // MARK: - Call Promise
    
    func testCallAsPromise_whenMakingRequestThrowsError_itRethrowsThatError() throws {
        let dummyError = DummyError()
        requestBuilder.stubbedMakeError = dummyError
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? DummyError, dummyError)
                expectation.fulfill()
            case .success:
                XCTFail(expectation.expectationDescription)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertFalse(middleware.invokedWillSend)
        XCTAssertFalse(middleware.invokedDidReceive)
    }
    
    func testCallAsPromise_whenReceiveNetworkError_itRethrowsThatError() throws {
        let dummyError = DummyError()
        session.set(stubbedResponseError: dummyError, for: request)
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            switch result {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail(expectation.expectationDescription)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
    
    func testCallAsPromise_whenReceiveResponseAndData_butMiddlewareThrowsError_itRethrowsThatError() throws {
        let dummyError = DummyError()
        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)
        middleware.stubbedDidReceiveError = dummyError
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? DummyError, dummyError)
                expectation.fulfill()
            case .success:
                XCTFail(expectation.expectationDescription)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
    
    func testCallAsPromise_whenReceiveResponse_withoutData_itThrowsError() throws {
        data = Data()
        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? NetworkableError, .empty)
                expectation.fulfill()
            case .success:
                XCTFail(expectation.expectationDescription)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
    
    func testCallAsPromise_whenReceiveResponseAndData_butDecodingThrowsError_itRethrowsThatError() throws {
        data = "%@#!@#".data(using: .utf8)
        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            switch result {
            case let .failure(error):
                XCTAssertTrue(error is DecodingError)
                expectation.fulfill()
            case .success:
                XCTFail(expectation.expectationDescription)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
    
    func testCallAsPromise_whenReceiveResponseAndData_itReturnResult() throws {
        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)
        let expectation = self.expectation(description: "expect receive value as completion")
        
        sut.call(to: endpoint) { (result: Result<DummyCodable, Error>) in
            switch result {
            case .failure:
                XCTFail(expectation.expectationDescription)
            case .success:
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
}

#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class DefaultWebRepository_Publisher_Tests: DefaultWebRepositoryTests {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = Set()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        cancellables = nil
    }
    
    // MARK: - Call - Publisher
    
    func testCallAsPublisher_whenMakingRequestThrowsError_itRethrowsThatError() throws {
        let dummyError = DummyError()
        requestBuilder.stubbedMakeError = dummyError
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint)
            .sink { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error) = completion else { return }
                XCTAssertEqual(error as? DummyError, dummyError)
                expectation.fulfill()
            } receiveValue: { (result: DummyCodable) in
                XCTFail(expectation.expectationDescription)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertFalse(middleware.invokedWillSend)
        XCTAssertFalse(middleware.invokedDidReceive)
    }
    
    func testCallAsPublisher_whenReceiveNetworkError_itRethrowsThatError() throws {
        let dummyError = DummyError()
        session.set(stubbedResponseError: dummyError, for: request)
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint)
            .sink { (completion: Subscribers.Completion<Error>) in
                guard case .failure = completion else { return }
                expectation.fulfill()
            } receiveValue: { (result: DummyCodable) in
                XCTFail(expectation.expectationDescription)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
    
    func testCallAsPublisher_whenReceiveResponseAndData_butMiddlewareThrowsError_itRethrowsThatError() throws {
        let dummyError = DummyError()
        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)
        middleware.stubbedDidReceiveError = dummyError
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint)
            .sink { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error) = completion else { return }
                XCTAssertEqual(error as? DummyError, dummyError)
                expectation.fulfill()
            } receiveValue: { (result: DummyCodable) in
                XCTFail(expectation.expectationDescription)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
    
    func testCallAsPublisher_whenReceiveResponse_withoutData_itThrowsError() throws {
        data = Data()
        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint)
            .sink { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error) = completion else { return }
                XCTAssertEqual(error as? NetworkableError, .empty)
                expectation.fulfill()
            } receiveValue: { (result: DummyCodable) in
                XCTFail(expectation.expectationDescription)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
    
    func testCallAsPublisher_whenReceiveResponseAndData_butDecodingThrowsError_itRethrowsThatError() throws {
        data = "%@#!@#".data(using: .utf8)
        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)
        let expectation = self.expectation(description: "expect receive failure as completion")
        
        sut.call(to: endpoint)
            .sink { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error) = completion else { return }
                XCTAssertTrue(error is DecodingError)
                expectation.fulfill()
            } receiveValue: { (result: DummyCodable) in
                XCTFail(expectation.expectationDescription)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
    
    func testCallAsPublisher_whenReceiveResponseAndData_itReturnResult() throws {
        session.set(stubbedResponse: response, for: request)
        session.set(stubbedData: data, for: request)
        let expectation = self.expectation(description: "expect receive value as completion")
        
        sut.call(to: endpoint)
            .sink { (completion: Subscribers.Completion<Error>) in
                guard case .failure = completion else { return }
                XCTFail(expectation.expectationDescription)
            } receiveValue: { (_: DummyCodable) in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(requestBuilder.invokedMake)
        XCTAssertTrue(middleware.invokedPrepare)
        XCTAssertTrue(middleware.invokedWillSend)
    }
}
#endif

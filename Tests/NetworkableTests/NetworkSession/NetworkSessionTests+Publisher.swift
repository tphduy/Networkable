//
//  NetworkSessionTests+Publisher.swift
//
//
//  Created by Duy Trần on 30/09/2022.
//


#if canImport(Combine)
import XCTest
import Combine
@testable import Networkable

@available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class NetworkSessionTests_Publisher: NetworkSessionTests {
    // MARK: Misc
    
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: Life Cycle
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = Set()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        cancellables = nil
    }
    
    // MARK: Test Cases - dataTaskPublisher(for:resultQueue:decoder:)
    
    func test_dataTaskPublisherWithDecodableResult_whenMiddlewareEncountersErrorAtPrepareRequest() throws {
        let expectation = expectation(description: "it should encounter an error.")
        let error = DummyError()
        middleware.stubbedPrepareError = error
        
        sut.dataTaskPublisher(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder())
        .sink { [unowned self] (completion) in
            guard case let .failure(failure) = completion else { return }
            XCTAssertEqual(failure as? DummyError, error)
            XCTAssertTrue(middleware.invokedPrepare)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, urlRequest)
            XCTAssertFalse(middleware.invokedWillSend)
            XCTAssertFalse(middleware.invokedDidReceiveResponse)
            XCTAssertFalse(middleware.invokedDidReceiveError)
            expectation.fulfill()
        } receiveValue: { (result: DummyCodable) in
            XCTFail(expectation.expectationDescription)
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_whenURLSessionEncountersError() throws {
        let expectation = expectation(description: "it should encounter an error.")
        let error = DummyError()
        StubbedURLProtocol.stubbedResponseError[urlRequest] = error
        
        sut.dataTaskPublisher(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder())
        .sink { [unowned self] (completion) in
            guard case let .failure(failure) = completion else { return }
            XCTAssertTrue(middleware.invokedPrepare)
            XCTAssertEqual(middleware.invokedPrepareParameters?.request, urlRequest)
            XCTAssertTrue(middleware.invokedWillSend)
            XCTAssertEqual(middleware.invokedWillSendParameters?.request, urlRequest)
            XCTAssertFalse(middleware.invokedDidReceiveResponse)
            XCTAssertTrue(middleware.invokedDidReceiveError)
            XCTAssertEqual(middleware.invokedDidReceiveErrorParameters?.error.localizedDescription, failure.localizedDescription)
            XCTAssertEqual(middleware.invokedDidReceiveErrorParameters?.request, urlRequest)
            expectation.fulfill()
        } receiveValue: { (result: DummyCodable) in
            XCTFail(expectation.expectationDescription)
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_whenMiddlewareEncountersErrorAtDidReceiveResponse() throws {
        let expectation = expectation(description: "it should encounter an error.")
        let error = DummyError()
        middleware.stubbedDidReceiveResponseError = error
        
        sut.dataTaskPublisher(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder())
        .sink { [unowned self] (completion) in
            guard case let .failure(failure) = completion else { return }
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
        } receiveValue: { (result: DummyCodable) in
            XCTFail(expectation.expectationDescription)
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_whenDecoderEncounterError() throws {
        let expectation = expectation(description: "it should encounter an error.")
        
        sut.dataTaskPublisher(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder())
        .sink { [unowned self] (completion) in
            guard case let .failure(failure) = completion else { return }
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
        } receiveValue: { (result: Int) in
            XCTFail(expectation.expectationDescription)
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_withoutResultQueue() throws {
        let expectation = expectation(description: "it should receive the value on the default queue.")
        
        sut.dataTaskPublisher(
            for: makeRequest(),
            resultQueue: nil,
            decoder: JSONDecoder())
        .sink { (completion) in
            guard case .failure = completion else { return }
            XCTFail(expectation.expectationDescription)
        } receiveValue: { (result: DummyCodable) in
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_withResultQueue() throws {
        let expectation = expectation(description: "it should receive the value on the main queue.")
        
        sut.dataTaskPublisher(
            for: makeRequest(),
            resultQueue: .main,
            decoder: JSONDecoder())
        .sink { (completion) in
            guard case .failure = completion else { return }
            XCTFail(expectation.expectationDescription)
        } receiveValue: { (result: DummyCodable) in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataTaskWithDecodableResult_withCustomDecoder() throws {
        struct SnakeCase: Decodable { let fooBar: Int }
        
        let expectation = expectation(description: "it should decode data successfully.")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        StubbedURLProtocol.stubbedData[urlRequest] = #"{"foo_bar":0}"#.data(using: .utf8)
        
        sut.dataTaskPublisher(
            for: makeRequest(),
            resultQueue: .main,
            decoder: decoder)
        .sink { (completion) in
            guard case .failure = completion else { return }
            XCTFail(expectation.expectationDescription)
        } receiveValue: { (result: SnakeCase) in
            XCTAssertEqual(result.fooBar, 0)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    // MARK: Test Cases - dataTaskPublisher(for:resultQueue:)
    
    func test_dataTaskPublisher() throws {
        let expectation = expectation(description: "it should receive the value.")
        
        sut.dataTaskPublisher(for: makeRequest(), resultQueue: .main)
            .sink { (completion) in
                guard case .failure = completion else { return }
                XCTFail(expectation.expectationDescription)
            } receiveValue: { (result: Void) in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
}
#endif

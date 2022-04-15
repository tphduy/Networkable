//
//  File.swift
//  
//
//  Created by Duy Tran on 15/04/2022.
//

#if canImport(Combine)
import Combine
import XCTest
@testable import Networkable

@available(iOS 13.0, *)
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
    
    // MARK: Test Cases - call(to:executionQueue:resultQueue:decoder:)
    
    func test_callAsPublisher_whenPreparing_andMiddlewareThrowError() throws {
        let expected = DummyError()
        middleware.stubbedPrepareError = expected
        
        let message = "expect throwing \(expected)"
        let expectation = self.expectation(description: message)
        
        sut.call(to: endpoint)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                guard case let .failure(error as DummyError) = completion else { return XCTFail(message) }
                XCTAssertEqual(error, expected)
                expectation.fulfill()
            }, receiveValue: { (_: DummyCodable) in
                XCTFail(message)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
    }
}
#endif

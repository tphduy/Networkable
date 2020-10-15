//
//  EndpointTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 8/25/20.
//

import XCTest
@testable import Networking

private final class EmptyEndpoint: Endpoint {
    var path: String { "" }
    var method: Networking.Method { .get }
}

final class EndpointTests: XCTestCase {

    private var sut: EmptyEndpoint!

    override func setUpWithError() throws {
        sut = EmptyEndpoint()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testHeader() throws {
        XCTAssertNil(sut.headers)
    }

    func testBody() throws {
        XCTAssertNoThrow(try sut.body())
        XCTAssertNil(try sut.body())
    }
}

//
//  LoadableTest.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import XCTest
@testable import Networking

final class LoadableTests: XCTestCase {
    var sut: Loadable<Int, Error>!

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testLoading() throws {
        sut = .loading
        XCTAssertTrue(sut.loading)

        sut = .value(0)
        XCTAssertFalse(sut.loading)

        sut = .error(DummyError())
        XCTAssertFalse(sut.loading)
    }

    func testError() throws {
        sut = .loading
        XCTAssertNil(sut.error)

        sut = .value(0)
        XCTAssertNil(sut.error)

        let error = DummyError()
        sut = .error(error)
        XCTAssertEqual(
            sut.error as! DummyError,
            error)
    }

    func testValue() throws {
        sut = .loading
        XCTAssertNil(sut.value)

        let value = 0
        sut = .value(value)
        XCTAssertEqual(
            sut.value,
            value)

        sut = .error(DummyError())
        XCTAssertNil(sut.value)
    }
}

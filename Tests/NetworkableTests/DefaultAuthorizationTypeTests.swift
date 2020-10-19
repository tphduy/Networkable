//
//  DefaultAuthorizationTypeTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/14/20.
//

import XCTest
@testable import Networkable

final class DefaultAuthorizationTypeTests: XCTestCase {

    let key = "key"
    let value = "value"
    let place = AuthorizationPlace.header

    func testInitWithDefaulParameters() {
        let sut = DefaultAuthorizationType(
            key: key,
            value: value)

        XCTAssertEqual(sut.key, key)
        XCTAssertEqual(sut.value, value)
        XCTAssertEqual(sut.place, .header)
    }

    func testInit() throws {

        let sut = DefaultAuthorizationType(
            key: key,
            value: value,
            place: place)

        XCTAssertEqual(sut.key, key)
        XCTAssertEqual(sut.value, value)
        XCTAssertEqual(sut.place, place)
    }
}

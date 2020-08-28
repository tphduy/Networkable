//
//  DefaultAuthorizationTypeTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/14/20.
//

@testable import Networking
import XCTest

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

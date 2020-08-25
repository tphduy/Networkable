//
//  DefaultAuthorizationTypeTests.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/14/20.
//

import XCTest
@testable import Networking

final class DefaultAuthorizationTypeTests: XCTestCase {
    
    func testAPIKeyAndValue() throws {
        let key = "key", value = "value", place = AuthorizationPlace.header
        let sut = DefaultAuthorizationType.api(key: key, value: value)

        XCTAssertEqual(sut.key, key)
        XCTAssertEqual(sut.value, value)
        XCTAssertEqual(sut.place, place)
    }

    func testBearer() throws {
        let token = "token", place = AuthorizationPlace.header
        let sut = DefaultAuthorizationType.bearer(token: token)

        XCTAssertEqual(sut.key, "Bearer ")
        XCTAssertEqual(sut.value, token)
        XCTAssertEqual(sut.place, place)
    }
}

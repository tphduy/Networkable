//
//  LoggingMiddlewareTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/15/20.
//

import XCTest
import os.log
@testable import Networkable

final class LoggingMiddlewareTests: XCTestCase {
    // MARK: Misc
    
    var request: URLRequest!
    var response: URLResponse!
    var type: OSLogType!
    var log: OSLog!
    var sut: LoggingMiddleware!
    
    // MARK: Life Cycle

    override func setUpWithError() throws {
        let url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        type = .info
        log = OSLog(subsystem: "com.duytph.UnitTest", category: "\(Self.self)")
        sut = LoggingMiddleware(type: type, log: log)
    }

    override func tearDownWithError() throws {
        request = nil
        response = nil
        type = nil
        log = nil
        sut = nil
    }
    
    // MARK: Test Cases - Init
    
    func test_init() {
        XCTAssertEqual(sut.type, type)
        XCTAssertEqual(sut.log, log)
    }
    
    // MARK: Test Cases - prepare(request:)
    
    func test_prepareRequest() throws {
        XCTAssertEqual(request, try sut.prepare(request: request))
    }
    
    // MARK: Test Cases - willSend(request:)
    
    func test_willSendRequest() throws {
        XCTAssertNoThrow(sut.willSend(request: request))
    }
    
    // MARK: Test Cases - didReceive(response:data)
    
    func test_didReceiveResponseAndData() throws {
        XCTAssertNoThrow(try sut.didReceive(response: response, data: Data()))
    }
    
    // MARK: Test Cases - log(request:)

    func test_logRequest() throws {
        let log = sut.log(request: request)
        let expected = request.logging()
        
        XCTAssertEqual(log, expected)
    }
    
    // MARK: Test Cases - log(response:data:)

    func test_logResponse_whenDataIsEmpty() throws {
        let data = Data()
        let expected = response.logging()
        let log = sut.log(response: response, data: data)
        
        XCTAssertEqual(log, expected)
    }

    func test_logResponse() throws {
        let rawData = #"{"lorem":"isplum""#
        let data = rawData.data(using: .utf8)!
        let expected = response.logging() + "\n" + rawData
        let log = sut.log(response: response, data: data)
        
        XCTAssertEqual(log, expected)
    }
}

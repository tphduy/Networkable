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
    
    var url: URL!
    var request: URLRequest!
    var response: URLResponse!
    var type: OSLogType!
    var log: OSLog!

    var sut: LoggingMiddleware!

    override func setUpWithError() throws {
        url = URL(string: "https://apple.com")!
        request = URLRequest(url: url)
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        type = .info
        log = OSLog(subsystem: "com.duytph.UnitTest", category: "\(Self.self)")

        sut = LoggingMiddleware(type: type, log: log)
    }

    override func tearDownWithError() throws {
        url = nil
        request = nil
        response = nil
        type = nil
        log = nil
        sut = nil
    }
    
    // MARK: - Init
    
    func testInit() {
        XCTAssertEqual(sut.type, type)
        XCTAssertEqual(sut.log, log)
    }
    
    // MARK: - Will Send Request
    
    func testWillSendRequest() throws {
        XCTAssertNoThrow(sut.willSend(request: request))
    }
    
    // MARK: - Prepare Request
    
    func testPrepareRequest() throws {
        let preparedRequest = try sut.prepare(request: request)
        
        XCTAssertEqual(request, preparedRequest)
    }
    
    // MARK: - Did Receive Response And Data
    
    func testDidReceiveResponseAndData() throws {
        let data = Data()
        
        XCTAssertNoThrow(try sut.didReceive(response: response, data: data))
    }
    
    // MARK: - Log Request

    func testLogRequest() throws {
        let log = sut.log(request: request)
        let expected = request.logging()
        
        XCTAssertEqual(log, expected)
    }
    
    // MARK: - Log Response

    func testLogResponse_whenDataIsEmpty() throws {
        let data = Data()
        let expected = response.logging()
        let log = sut.log(response: response, data: data)
        
        XCTAssertEqual(log, expected)
    }

    func testLogResponse() throws {
        let rawData = #"{"lorem":"isplum""#
        let data = rawData.data(using: .utf8)!
        let expected = response.logging() + "\n" + rawData
        
        let log = sut.log(response: response, data: data)
        
        XCTAssertEqual(log, expected)
    }
}

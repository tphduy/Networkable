//
//  AuthorizationMiddlewareTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

import XCTest
@testable import Networkable

final class AuthorizationMiddlewareTests: XCTestCase {
    
    var queryItems1: URLQueryItem!
    var queryItems2: URLQueryItem!
    var urlComponents: URLComponents!
    var header1: (key: String, value: String)!
    var header2: (key: String, value: String)!
    var request: URLRequest!
    var response: URLResponse!
    var key: String!
    var value: String!
    var place: AuthorizationMiddleware.Place!
    var sut: AuthorizationMiddleware!

    override func setUpWithError() throws {
        queryItems1 = URLQueryItem(name: "foo", value: "bar")
        queryItems2 = URLQueryItem(name: "fizz", value: "buzz")
        urlComponents = URLComponents(string: "https://apple.com/foo/bar")
        urlComponents.queryItems = [queryItems1, queryItems2]
        header1 = (key: "Foo", value: "Bar")
        header2 = (key: "Fizz", value: "Buzz")
        request = URLRequest(url: urlComponents.url!)
        request.addValue(header1.value, forHTTPHeaderField: header1.key)
        request.addValue(header2.value, forHTTPHeaderField: header2.key)
        response = HTTPURLResponse(url: urlComponents.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        key = "Authorization"
        value = "Bearer L8qq9PZyRg6ieKGEKhZolGC0vJWLw8iEJ88DRdyOg"
        place = .header
        sut = AuthorizationMiddleware(key: key, value: value, place: place)
    }

    override func tearDownWithError() throws {
        queryItems1 = nil
        queryItems2 = nil
        urlComponents = nil
        header1 = nil
        header2 = nil
        request = nil
        response = nil
        key = nil
        value = nil
        place = nil
        sut = nil
    }
    
    // MARK: - Init

    func testInit() throws {
        XCTAssertEqual(sut.key, key)
        XCTAssertEqual(sut.value, value)
        XCTAssertEqual(sut.place, place)
    }
    
    // MARK: - Prepare Request
    
    func testPrepareRequest_whenKeyIsEmpty_itDoesNothing() throws {
        sut.key = ""
        
        XCTAssertTrue(sut.key.isEmpty)
        XCTAssertFalse(sut.value.isEmpty)
        
        sut.place = .header
        
        XCTAssertEqual(try sut.prepare(request: request), request)
        
        sut.place = .query
        
        XCTAssertEqual(try sut.prepare(request: request), request)
    }
    
    func testPrepareRequest_whenValueIsEmpty_itDoesNothing() throws {
        sut.value = ""
        
        XCTAssertFalse(sut.key.isEmpty)
        XCTAssertTrue(sut.value.isEmpty)
        
        sut.place = .header
    
        XCTAssertEqual(try sut.prepare(request: request), request)
        
        sut.place = .query
        
        XCTAssertEqual(try sut.prepare(request: request), request)
    }
    
    func testPrepareRequest_whenPlaceIsHeader_withoutModifyingOriginHeaders_itAppendsAuthorizationHeader() throws {
        XCTAssertEqual(request.value(forHTTPHeaderField: header1.key), header1.value)
        XCTAssertEqual(request.value(forHTTPHeaderField: header2.key), header2.value)
        
        let preparedRequest = try sut.prepare(request: request)
        
        XCTAssertEqual(request.value(forHTTPHeaderField: header1.key), header1.value)
        XCTAssertEqual(request.value(forHTTPHeaderField: header2.key), header2.value)
        XCTAssertEqual(preparedRequest.value(forHTTPHeaderField: key), value)
    }
    
    func testPrepareRequest_whenPlaceIsQuery_andURLIsAbsent_itDoesNothing() throws {
        sut.place = .query
        request.url = nil
        
        let preparedRequest = try sut.prepare(request: request)
        
        XCTAssertEqual(preparedRequest, request)
    }
    
    func testPrepareRequest_whenPlaceIsQuery_andQueryIsNonExistent_itAppendsAuthorizationQuery() throws {
        urlComponents.queryItems = nil
        request = URLRequest(url: urlComponents.url!)
        sut.place = .query
        
        XCTAssertNil(urlComponents.queryItems)
        XCTAssertEqual(urlComponents.url, request.url)
        
        let preparedRequest = try sut.prepare(request: request)
        let preparedURLComponents = URLComponents(url: preparedRequest.url!, resolvingAgainstBaseURL: true)!
        
        XCTAssertNotNil(preparedURLComponents.queryItems)
        XCTAssertTrue(preparedURLComponents.queryItems!.contains(where: { (queryItem: URLQueryItem) -> Bool in
            queryItem.name == key && queryItem.value == value
        }))
    }
    
    func testPrepareRequest_whenPlaceIsQuery_withoutModifyingOriginalQuery_itAppendsAuthorizationQuery() throws {
        sut.place = .query
        
        XCTAssertTrue(urlComponents.queryItems!.contains(queryItems1))
        XCTAssertTrue(urlComponents.queryItems!.contains(queryItems2))
        XCTAssertEqual(urlComponents.url, request.url)
        
        let preparedRequest = try sut.prepare(request: request)
        let preparedURLComponents = URLComponents(url: preparedRequest.url!, resolvingAgainstBaseURL: true)!
        
        XCTAssertTrue(preparedURLComponents.queryItems!.contains(queryItems1))
        XCTAssertTrue(preparedURLComponents.queryItems!.contains(queryItems2))
        XCTAssertTrue(preparedURLComponents.queryItems!.contains(where: { (queryItem: URLQueryItem) -> Bool in
            queryItem.name == key && queryItem.value == value
        }))
    }
    
    // MARK: - Will Send Request

    func testWillSendRequest() throws {
        XCTAssertNoThrow(sut.willSend(request: request))
    }

    // MARK: - Did Receive Response And Data

    func testDidReceiveResponseAndData() throws {
        XCTAssertNoThrow(try sut.didReceive(response: response, data: Data()))
    }
    
    // MARK: - Authorize Request
    
    func testAuthorizeRequest_whenKeyIsEmpty_itDoesNothing() throws {
        sut.key = ""
        
        XCTAssertTrue(sut.key.isEmpty)
        XCTAssertFalse(sut.value.isEmpty)
        
        sut.place = .header
        
        XCTAssertEqual(sut.authorize(request: request), request)
        
        sut.place = .query
        
        XCTAssertEqual(sut.authorize(request: request), request)
    }
    
    func testAuthorizeRequest_whenValueIsEmpty_itDoesNothing() throws {
        sut.value = ""
        
        XCTAssertFalse(sut.key.isEmpty)
        XCTAssertTrue(sut.value.isEmpty)
        
        sut.place = .header
    
        XCTAssertEqual(sut.authorize(request: request), request)
        
        sut.place = .query
        
        XCTAssertEqual(sut.authorize(request: request), request)
    }
    
    func testAuthorizeRequest_whenPlaceIsHeader_withoutModifyingOriginHeaders_itAppendsAuthorizationHeader() throws {
        XCTAssertEqual(request.value(forHTTPHeaderField: header1.key), header1.value)
        XCTAssertEqual(request.value(forHTTPHeaderField: header2.key), header2.value)
        
        let preparedRequest = sut.authorize(request: request)
        
        XCTAssertEqual(request.value(forHTTPHeaderField: header1.key), header1.value)
        XCTAssertEqual(request.value(forHTTPHeaderField: header2.key), header2.value)
        XCTAssertEqual(preparedRequest.value(forHTTPHeaderField: key), value)
    }
    
    func testAuthorizeRequest_whenPlaceIsQuery_andURLIsAbsent_itDoesNothing() throws {
        sut.place = .query
        request.url = nil
        
        let preparedRequest = sut.authorize(request: request)
        
        XCTAssertEqual(preparedRequest, request)
    }
    
    func testAuthorizeRequest_whenPlaceIsQuery_andQueryIsNonExistent_itAppendsAuthorizationQuery() throws {
        urlComponents.queryItems = nil
        request = URLRequest(url: urlComponents.url!)
        sut.place = .query
        
        XCTAssertNil(urlComponents.queryItems)
        XCTAssertEqual(urlComponents.url, request.url)
        
        let preparedRequest = sut.authorize(request: request)
        let preparedURLComponents = URLComponents(url: preparedRequest.url!, resolvingAgainstBaseURL: true)!
        
        XCTAssertNotNil(preparedURLComponents.queryItems)
        XCTAssertTrue(preparedURLComponents.queryItems!.contains(where: { (queryItem: URLQueryItem) -> Bool in
            queryItem.name == key && queryItem.value == value
        }))
    }
    
    func testAuthorizeRequest_whenPlaceIsQuery_withoutModifyingOriginalQuery_itAppendsAuthorizationQuery() throws {
        sut.place = .query
        
        XCTAssertTrue(urlComponents.queryItems!.contains(queryItems1))
        XCTAssertTrue(urlComponents.queryItems!.contains(queryItems2))
        XCTAssertEqual(urlComponents.url, request.url)
        
        let preparedRequest = sut.authorize(request: request)
        let preparedURLComponents = URLComponents(url: preparedRequest.url!, resolvingAgainstBaseURL: true)!
        
        XCTAssertTrue(preparedURLComponents.queryItems!.contains(queryItems1))
        XCTAssertTrue(preparedURLComponents.queryItems!.contains(queryItems2))
        XCTAssertTrue(preparedURLComponents.queryItems!.contains(where: { (queryItem: URLQueryItem) -> Bool in
            queryItem.name == key && queryItem.value == value
        }))
    }
}

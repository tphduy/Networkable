//
//  AuthorizationMiddlewareTests.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

import XCTest
@testable import Networkable

final class AuthorizationMiddlewareTests: XCTestCase {
    // MARK: Misc
    
    private var urlComponents: URLComponents!
    private var request: URLRequest!
    private var response: URLResponse!
    private var key: String!
    private var value: String!
    private var place: AuthorizationMiddleware.Place!
    private var sut: AuthorizationMiddleware!
    
    // MARK: Life Cycle

    override func setUpWithError() throws {
        urlComponents = makeURLComponents()
        request = makeRequest()
        response = makeResponse()
        key = "Authorization"
        value = "Bearer L8qq9PZyRg6ieKGEKhZolGC0vJWLw8iEJ88DRdyOg"
        place = .header
        sut = AuthorizationMiddleware(
            key: key,
            value: value,
            place: place)
    }

    override func tearDownWithError() throws {
        urlComponents = nil
        request = nil
        response = nil
        key = nil
        value = nil
        place = nil
        sut = nil
    }
    
    // MARK: Test Cases - init(key:value:place)

    func testInit() throws {
        XCTAssertEqual(sut.key, key)
        XCTAssertEqual(sut.value, value)
        XCTAssertEqual(sut.place, place)
    }
    
    // MARK: Test Cases - prepare(request:)
    
    func test_prepareRequest_whenKeyIsEmpty() throws {
        sut.key = ""
        
        XCTAssertEqual(request, try sut.prepare(request: request))
    }
    
    func test_prepareRequest_whenValueIsEmpty() throws {
        sut.value = ""
        
        XCTAssertEqual(request, try sut.prepare(request: request))
    }
    
    func test_prepareRequest_whenPlaceIsHeader() throws {
        sut.place = .header
        
        let result = try sut.prepare(request: request)
        let resultHeaders = result.allHTTPHeaderFields
        let expectedHeaders = request
            .allHTTPHeaderFields?
            .merging([key: value], uniquingKeysWith: { $1 })
        
        XCTAssertNotEqual(result, request)
        XCTAssertEqual(resultHeaders, expectedHeaders)
    }
    
    func test_prepareRequest_whenPlaceIsQuery() throws {
        sut.place = .query
        
        let result = try sut.prepare(request: request)
        let predicate: (URLQueryItem, URLQueryItem) -> Bool = { $0.name < $1.name }
        let resultQuery = URLComponents(url: result.url!, resolvingAgainstBaseURL: true)!
            .queryItems?
            .sorted(by: predicate)
        let expectedQuery = (makeQueryItems() + [URLQueryItem(name: key, value: value)])
            .sorted(by: predicate)
        XCTAssertNotEqual(result, request)
        XCTAssertEqual(resultQuery, expectedQuery)
    }
    
    // MARK: Test Cases - willSend(request:)
    
    func willSend(request: URLRequest) {
        sut.willSend(request: request)
    }
    
    // MARK: Test Cases - didReceive(response:data:)
    
    func didReceive(response: URLResponse, data: Data) throws {
        XCTAssertNoThrow(try sut.didReceive(response: response, data: data))
    }
    
    // MARK: Test Cases - didReceive(error:of:)
    
    func didReceive(error: Error, of request: URLRequest) {
        sut.didReceive(error: DummyError(), of: request)
    }
}

extension AuthorizationMiddlewareTests {
    // MARK: Utilities
    
    private func makeQueryItems() -> [URLQueryItem] {
        [
            URLQueryItem(name: "foo", value: "bar"),
            URLQueryItem(name: "fizz", value: "buzz"),
        ]
    }
    
    private func makeURLComponents() -> URLComponents {
        var result = URLComponents(string: "https://apple.com/foo/bar")!
        result.queryItems = makeQueryItems()
        return result
    }
    
    private func makeRequest() -> URLRequest {
        var result = URLRequest(url: urlComponents.url!)
        result.addValue("Foo", forHTTPHeaderField: "Bar")
        result.addValue("Fizz", forHTTPHeaderField: "Buzz")
        return result
    }
    
    private func makeResponse() -> URLResponse {
        HTTPURLResponse(
            url: urlComponents.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
    }
}

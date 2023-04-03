//
//  Request.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// A type that abstracts an HTTP request.
///
/// An HTTP request is an action to be performed on a resource, identified by a given URL.
/// Read more at [Mozilla](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview).
public protocol Request {
    /// A list of HTTP headers that let the client pass additional information with a request.
    ///
    /// Reads more at [Mozilla](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers).
    var headers: [String: String]? { get }
    
    /// A relative URL that identifies the location of a resource.
    ///
    /// If an absolute URL is returned when this object is consumed by `URLRequestBuilder`, it will override the value of `URLRequestBuilder.baseURL`.
    ///
    /// Reads more at [Mozilla](https://developer.mozilla.org/en-US/docs/Learn/Common_questions/What_is_a_URL#absolute_urls_vs_relative_urls).
    var url: String { get }
    
    /// An HTTP method indicate the desired action to be performed for a given resource.
    ///
    /// Reads more at [Mozilla](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods).
    var method: Method { get }
    
    /// The data sent as the message body of the request.
    ///
    /// Reads more at [Mozilla](https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages#body).
    func body() throws -> Data?
}

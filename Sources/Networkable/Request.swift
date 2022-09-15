//
//  Request.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// An object abstracts a HTTP request.
public protocol Request {
    /// A list of HTTP headers that let the client pass additional information with a request.
    ///
    /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers).
    var headers: [String: String]? { get }
    
    /// A relative URL that identifies the location of a resource.
    ///
    /// https://developer.mozilla.org/en-US/docs/Learn/Common_questions/What_is_a_URL#absolute_urls_vs_relative_urls.
    var url: String { get }
    
    /// An HTTP method indicate the desired action to be performed for a given resource.
    ///
    /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods.
    var method: Method { get }
    
    /// The data sent as the message body of the request.
    ///
    /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages#body
    func body() throws -> Data?
}

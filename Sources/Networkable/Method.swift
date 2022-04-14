//
//  Method.swift
//  Networkable
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

/// The object re-presents the HTTP methods to indicate the desired action to be performed for a given resource
///
/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods.
public enum Method: String, Hashable, CaseIterable {
    /// Requests a representation of the specified resource. Requests using GET should only retrieve data.
    case get
    
    /// Asks for a response identical to that of a GET request, but without the response body.
    case head
    
    /// Submit an entity to the specified resource
    case post
    
    /// Replaces all current representations of the target resource with the request payload.
    case put
    
    /// Deletes the specified resource.
    case delete
    
    /// Establishes a tunnel to the server identified by the target resource.
    case connect
    
    /// Describe the communication options for the target resource.
    case options
    
    /// Performs a message loop-back test along the path to the target resource.
    case trace
    
    /// Apply partial modifications to a resource.
    case patch
}

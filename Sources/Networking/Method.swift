//
//  Method.swift
//  Networking
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

public enum Method: String, Hashable, Equatable, CaseIterable {
    case get
    case post
    case put
    case patch
    case delete
}

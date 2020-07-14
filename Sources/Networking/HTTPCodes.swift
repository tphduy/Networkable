//
//  HTTPCodes.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

public typealias HTTPCode = Int
public typealias HTTPCodes = ClosedRange<HTTPCode>

extension HTTPCodes {
    public static var success = 200 ... 299
    public static var successAndRedirection = 300 ... 399
    public static var error = 400 ... 499
    public static var serverError = 500 ... 511
}

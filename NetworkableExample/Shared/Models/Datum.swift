//
//  Datum.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 16/04/2022.
//

import Foundation

/// An object that helps to flatten a JSON object to parse the actual data within.
struct Datum<T: Codable>: Codable {
    /// The actual data.
    let data: T
}

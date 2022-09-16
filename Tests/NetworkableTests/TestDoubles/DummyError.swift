//
//  DummyError.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/12/20.
//

import Foundation

struct DummyError: LocalizedError, Equatable {
    
    let id = UUID()
    
    var errorDescription: String? {
        id.uuidString
    }
}

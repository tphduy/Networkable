//
//  OSLog+Network.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 21/11/2022.
//

import Foundation
import os.log

extension OSLog {
    /// An object for writing interpolated string messages to the unified logging system that describes the network usages.
    static var network: OSLog {
        OSLog(subsystem: Bundle.main.bundleIdentifier ?? "", category: #function)
    }
}

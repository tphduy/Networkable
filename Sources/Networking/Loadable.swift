//
//  Loadable.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

import Foundation

public enum Loadable<T, E: Error> {
    case loading
    case value(T)
    case error(E)
}

extension Loadable {
    public var loading: Bool {
        if case .loading = self {
            return true
        } else {
            return false
        }
    }

    public var error: E? {
        if case let .error(error) = self {
            return error
        } else {
            return nil
        }
    }

    public var value: T? {
        if case let .value(value) = self {
            return value
        } else {
            return nil
        }
    }
}

extension Loadable: Equatable where T: Equatable, E: Equatable {}

extension Loadable: Hashable where T: Hashable, E: Hashable {}

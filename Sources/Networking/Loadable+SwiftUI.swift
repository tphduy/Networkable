//
//  Loadable+SwiftUI.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
extension Loadable {
    public func isLoading<Content: View>(@ViewBuilder content: @escaping () -> Content) -> Content? {
        if loading {
            return content()
        } else {
            return nil
        }
    }

    public func hasValue<Content: View>(@ViewBuilder content: @escaping (T) -> Content) -> Content? {
        if let value = value {
            return content(value)
        } else {
            return nil
        }
    }

    public func hasError<Content: View>(@ViewBuilder content: @escaping (Error) -> Content) -> Content? {
        if let error = error {
            return content(error)
        } else {
            return nil
        }
    }
}
#endif

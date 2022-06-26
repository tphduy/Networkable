//
//  Reachability.swift
//  Reachability
//
//  Created by Duy Tran on 24/06/2022.
//

import Foundation
import Network
#if canImport(UIKit)
import UIKit
#endif

/// An object that observes to the network path status and report the changes to a notification center.
@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 5.0, *)
public final class Reachability {
    /// A shared instance.
    public static let shared = Reachability()
    
    // MARK: Dependencies
    
    /// An observer that you use to monitor and react to network changes.
    private let monitor: NWPathMonitor
    
    /// A notification dispatch mechanism that is used to observe the application life cycle notifications.
    private let notificationCenter: NotificationCenter
    
    // MARK: Init
    
    /// Initiate an object that observes to the network path status and report the changes to a notification center.
    /// - Parameters:
    ///   - monitor: An observer that you use to monitor and react to network changes.
    ///   - notificationCenter: A notification dispatch mechanism that is used to observe the application life cycle notifications. The default value is `.default`
    public init(
        monitor: NWPathMonitor = NWPathMonitor(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.monitor = monitor
        self.notificationCenter = notificationCenter
    }
    
    // MARK: Side Effects
    
    /// Start monitoring path changes on `monitorQueue`.
    /// - Parameter queue: A queue to starts monitoring path changes.
    public func start(queue: DispatchQueue = .global(qos: .background)) {
        monitor.pathUpdateHandler = { [weak self] (path: NWPath) in
            guard let self = self else { return }
            let name = self.notificationName(for: path.status)
            self.notificationCenter.post(name: name, object: self)
        }
        monitor.start(queue: queue)
    }
    
    /// Stop monitoring network path updates.
    public func cancel() {
        monitor.cancel()
        monitor.pathUpdateHandler = nil
    }
    
    // MARK: Utilities
    
    /// Determine whether the network is connected.
    /// - Returns: `true` is the network is connected, otherwise, `false`.
    public func isConnected() -> Bool {
        monitor.currentPath.status == .satisfied
    }
    
    /// Transform a network path status to an associated notification name.
    /// - Parameter status: Status values indicating whether a path can be used by connections.
    /// - Returns: A value in `networkDidConnect`, `.networkDidDisconnect`, `networkDidSuspend`.
    func notificationName(for status: NWPath.Status) -> Notification.Name {
        switch status {
        case .satisfied:
            return Self.networkDidConnect
        case .unsatisfied:
            return Self.networkDidDisconnect
        case .requiresConnection:
            return Self.networkDidSuspend
        @unknown default:
            return Self.networkDidSuspend
        }
    }
    
    // MARK: Notification Names
    
    /// A notification that posts when the network did connect.
    public static var networkDidConnect: Notification.Name {
        Notification.Name(rawValue: #function)
    }
    
    /// A notification that posts when the network did disconnect.
    public static var networkDidDisconnect: Notification.Name {
        Notification.Name(rawValue: #function)
    }
    
    /// A notification that posts when the network did suspend.
    public static var networkDidSuspend: Notification.Name {
        Notification.Name(rawValue: #function)
    }
}

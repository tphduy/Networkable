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
    
    /// A queue to starts monitoring path changes.
    private let monitorQueue: DispatchQueue
    
    /// A notification dispatch mechanism that is used to observe the application life cycle notifications.
    private let notificationCenter: NotificationCenter
    
    /// A queue to observe the application life cycle notifications.
    private let notificationObservationQueue: OperationQueue?
    
    // MARK: Misc
    
    /// An object that keeps a reference to the `UIApplication.willEnterForegroundNotification` observation.
    private(set) var willEnterForegroundObservation: NSObjectProtocol?
    
    /// An object that keeps a reference to the `UIApplication.didEnterBackgroundNotification` observation.
    private(set) var didEnterBackgroundObservation: NSObjectProtocol?
    
    // MARK: Init
    
    /// Initiate an object that observes to the network path status and report the changes to a notification center.
    /// - Parameters:
    ///   - monitor: An observer that you use to monitor and react to network changes.
    ///   - monitorQueue: A queue to starts monitoring path changes. The default value is `.global(qos: .background)`
    ///   - notificationCenter: A notification dispatch mechanism that is used to observe the application life cycle notifications. The default value is `.default`
    ///   - notificationObservationQueue: A queue to observe the application life cycle notifications. The default value is `none`.
    public init(
        monitor: NWPathMonitor = NWPathMonitor(),
        monitorQueue: DispatchQueue = .global(qos: .background),
        notificationCenter: NotificationCenter = .default,
        notificationObservationQueue: OperationQueue? = nil
    ) {
        self.monitor = monitor
        self.monitorQueue = monitorQueue
        self.notificationCenter = notificationCenter
        self.notificationObservationQueue = notificationObservationQueue
    }
    
    // MARK: Side Effects
    
#if !os(watchOS) && !os(macOS)
    /// Observe to the `UIApplication.willEnterForegroundNotification` notification if it hasn't been done before.
    ///
    /// it will start monitoring the network path status when the application is about to enter foreground.
    private func observeApplicationWillEnterForegroundIfNeeded() {
        guard willEnterForegroundObservation == nil else { return }
        willEnterForegroundObservation = notificationCenter.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: nil
        ) { [weak self] (_: Notification) in
            self?.start()
        }
    }
    
    /// Observe to the `UIApplication.didEnterBackgroundNotification` notification if it hasn't been done before.
    ///
    /// it will stop monitoring the network path status when the application did enter background.
    private func observeApplicationDidEnterBackgroundIfNeeded() {
        guard didEnterBackgroundObservation == nil else { return }
        didEnterBackgroundObservation = notificationCenter.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: nil
        ) { [weak self] (_: Notification) in
            self?.cancel()
        }
    }
#endif
    
    /// Perform any necessary task and observe to the application life cycle events for start/stop monitoring network path status.
    public func bootstrap() {
#if !os(watchOS) && !os(macOS)
        observeApplicationWillEnterForegroundIfNeeded()
        observeApplicationDidEnterBackgroundIfNeeded()
#endif
    }
    
    /// Start monitoring path changes on `monitorQueue`.
    public func start() {
        monitor.pathUpdateHandler = { [weak self] (path: NWPath) in
            guard let self = self else { return }
            let name = self.notificationName(for: path.status)
            self.notificationCenter.post(name: name, object: self)
        }
        monitor.start(queue: monitorQueue)
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

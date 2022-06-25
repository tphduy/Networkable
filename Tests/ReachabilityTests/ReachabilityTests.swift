//
//  ReachabilityTests.swift
//  
//
//  Created by Duy Tran on 24/06/2022.
//

import XCTest
import Network
@testable import Reachability

@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 5.0, *)
final class ReachabilityTests: XCTestCase {
    // MARK: Misc
    
    private var monitor: NWPathMonitor!
    private var monitorQueue: DispatchQueue!
    private var notificationCenter: NotificationCenter!
    private var notificationObservationQueue: OperationQueue!
    private var sut: Reachability!
    
    // MARK: Life Cycle
    
    override func setUpWithError() throws {
        monitor = NWPathMonitor()
        monitorQueue = DispatchQueue(label: String(describing: Self.self), qos: .background)
        notificationCenter = NotificationCenter()
        notificationObservationQueue =  OperationQueue()
        sut = Reachability(
            monitor: monitor,
            monitorQueue: monitorQueue,
            notificationCenter: notificationCenter,
            notificationObservationQueue: notificationObservationQueue)
    }
    
    override func tearDownWithError() throws {
        monitor = nil
        monitorQueue = nil
        notificationCenter = nil
        notificationObservationQueue = nil
        sut = nil
    }
    
    // MARK: Test Case - boostrap()
    
    func test_bootstrap() throws {
        sut.bootstrap()
        
#if !os(watchOS) && !os(macOS)
        XCTAssertNotNil(sut.willEnterForegroundObservation)
        XCTAssertNotNil(sut.didEnterBackgroundObservation)
#endif
    }
    
    // MARK: Test Case - start()
    
    func test_start() throws {
        sut.start()
        
        XCTAssertNotNil(monitor.pathUpdateHandler)
        XCTAssertEqual(monitor.queue, monitorQueue)
    }
    
    // MARK: Test Case - cancel()
    
    func test_cancel() throws {
        sut.start()
        
        XCTAssertNotNil(monitor.pathUpdateHandler)
        
        sut.cancel()
        
        XCTAssertNil(monitor.pathUpdateHandler)
    }
    
    // MARK: Test Case - isConnected()
    
    func test_isConnected() throws {
        let expected = monitor.currentPath.status == .satisfied
        XCTAssertEqual(sut.isConnected(), expected)
    }
    
    // MARK: Test Case - notificationName(for:)
    
    func test_notificationName() throws {
        XCTAssertEqual(sut.notificationName(for: .satisfied), Reachability.networkDidConnect)
        XCTAssertEqual(sut.notificationName(for: .unsatisfied), Reachability.networkDidDisconnect)
        XCTAssertEqual(sut.notificationName(for: .requiresConnection), Reachability.networkDidSuspend)
    }
}

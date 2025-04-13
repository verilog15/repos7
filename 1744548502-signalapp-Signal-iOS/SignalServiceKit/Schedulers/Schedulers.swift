//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

/// In production code, transparent wrapper around `DispatchQueue` static methods
/// of the same name.
/// In tests, allows the test code to control which thread everything runs in.
public protocol Schedulers {

    /// A scheduler that executes any work item on the same thread
    /// as it was called on, synchronously, even if called with `async`.
    /// Useful for when you don't care what thread some block executes on
    /// and want to incur the least overhead possible.
    var sync: Scheduler { get }

    /// Analogous to `DispatchQueue.main`.
    var main: Scheduler { get }

    /// Analogous to `DispatchQueue.global(qos:)`.
    func global(qos: DispatchQoS.QoSClass) -> Scheduler

    /// Analogous to `DispatchQueue.sharedUserInteractive`.
    var sharedUserInteractive: Scheduler { get }

    /// Analogous to `DispatchQueue.sharedUserInitiated`.
    var sharedUserInitiated: Scheduler { get }

    /// Analogous to `DispatchQueue.sharedUtility`.
    var sharedUtility: Scheduler { get }

    /// Returns the shared serial queue appropriate for the provided QoS
    func sharedQueue(at qos: DispatchQoS) -> Scheduler

    /// Equivalent to the `DispatchQueue` initializer.
    func queue(
        label: String,
        qos: DispatchQoS,
        attributes: DispatchQueue.Attributes,
        autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency,
        target: DispatchQueue?
    ) -> Scheduler
}

extension Schedulers {

    /// Analogous to `DispatchQueue.global()`.
    public func global() -> Scheduler {
        return global(qos: .default)
    }

    /// Equivalent to the `DispatchQueue` initializer.
    public func queue(label: String) -> Scheduler {
        return queue(label: label, qos: .unspecified)
    }

    /// Equivalent to the `DispatchQueue` initializer.
    public func queue(
        label: String,
        qos: DispatchQoS
    ) -> Scheduler {
        return queue(
            label: label,
            qos: qos,
            attributes: [],
            autoreleaseFrequency: .inherit,
            target: nil
        )
    }
}

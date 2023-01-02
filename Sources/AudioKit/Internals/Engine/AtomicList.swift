// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import Atomics

/// An atomic list we can use as a work queue among multiple threads.
///
/// Note that item data is stored in a parallel array. Also, this list suffers from the ABA problem,
/// but we will not be pushing a single item more than once.
public class AtomicList {
    var head = ManagedAtomic<Int>(-1)
    var items: [ManagedAtomic<Int>] = []

    /// Create an atomic list with a fixed number of potential items.
    public init(size: Int) {
        for i in 0..<size {
            items.append(.init(-1))
        }
    }

    /// Clear the list. This is not thread safe.
    public func clear() {
        for i in 0..<items.count {
            items[i].store(-1, ordering: .relaxed)
        }
    }

    /// Push an index.
    public func push(_ value: Int) {
        assert(value < items.count)

        var oldHead = head.load(ordering: .relaxed)
        items[value].store(oldHead, ordering: .relaxed)

        // Spin until we successfully push.
        while true {
            let (exchanged, original) = head.compareExchange(expected: oldHead, desired: value, ordering: .relaxed)

            if exchanged {
                break
            }

            oldHead = original
            items[value].store(oldHead, ordering: .relaxed)
        }

    }

    /// Pop an index.
    public func pop() -> Int? {

        var oldHead = head.load(ordering: .relaxed)
        if oldHead == -1 {
            return nil
        }

        // Spin until we successfullly pop.
        while true {
            let desired = items[oldHead].load(ordering: .relaxed)
            let (exchanged, original) = head.compareExchange(expected: oldHead, desired: desired, ordering: .relaxed)

            if exchanged {
                break
            }

            oldHead = original
            if oldHead == -1 {
                return nil
            }
        }

        // Clear the next item for the one we popped.
        items[oldHead].store(-1, ordering: .relaxed)

        return oldHead
    }
}

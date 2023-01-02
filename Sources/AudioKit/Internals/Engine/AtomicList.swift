// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import Atomics

/// An atomic list we can use as a work queue among multiple threads.
///
/// Note that item data is stored in a parallel array. Also, this list suffers from the ABA problem,
/// but we will not be pushing a single item more than once.
public class AtomicList {
    var head = ManagedAtomic<Int>(-1)
    var items: UnsafeMutableBufferPointer<Int>

    /// Create an atomic list with a fixed number of potential items.
    public init(size: Int) {
        self.items = UnsafeMutableBufferPointer.allocate(capacity: size)
        clear()
    }

    deinit {
        self.items.deallocate()
    }

    /// Clear the list. This is not thread safe.
    public func clear() {
        for i in 0..<items.count {
            items[i] = -1
        }
    }

    /// Push an index.
    public func push(_ value: Int) {
        assert(value < items.count)

        var oldHead = head.load(ordering: .relaxed)
        items[value] = oldHead

        // Spin until we successfully push.
        while true {
            let (exchanged, original) = head.compareExchange(expected: oldHead, desired: value, ordering: .relaxed)

            if exchanged {
                break
            }

            oldHead = original
            items[value] = oldHead
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
            let (exchanged, original) = head.compareExchange(expected: oldHead, desired: items[oldHead], ordering: .relaxed)

            if exchanged {
                break
            }

            oldHead = original
            if oldHead == -1 {
                return nil
            }
        }

        return oldHead
    }
}

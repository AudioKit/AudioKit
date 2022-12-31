// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// An atomic list we can use as a work queue among multiple threads.
///
/// Note that item data is stored in a parallel array. Also, this list suffers from the ABA problem,
/// but we will not be pushing a single item more than once.
struct AtomicList {
    var head: Int = -1
    var items: [Int]

    /// Create an atomic list with a fixed number of potential items.
    init(size: Int) {
        self.items = .init(repeating: -1, count: size)
    }

    /// Push an index.
    mutating func push(_ value: Int) {
        assert(value < items.count)

        var oldHead = head
        items[value] = oldHead

        // Spin until we successfully push.
        while !OSAtomicCompareAndSwapLong(oldHead, value, &head) {
            oldHead = head
            items[value] = oldHead
        }

    }

    /// Pop an index.
    mutating func pop() -> Int? {

        if head == -1 {
            return nil
        }

        var oldHead = head

        // Spin until we successfullly pop.
        while !OSAtomicCompareAndSwapLong(oldHead, items[oldHead], &head) {
            oldHead = head
        }

        return oldHead
    }
}

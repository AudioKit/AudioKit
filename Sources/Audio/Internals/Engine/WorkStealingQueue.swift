

import Atomics
import Foundation

/// Lock-free unbounded single-producer multiple-consumer queue.
///
/// This class implements the work stealing queue described in the paper,
/// "Correct and Efficient Work-Stealing for Weak Memory Models,"
/// available at https://www.di.ens.fr/~zappa/readings/ppopp13.pdf.
///
/// Only the queue owner can perform pop and push operations,
/// while others can steal data from the queue.
/// Ported to swift from C++: https://github.com/taskflow/work-stealing-queue
public class WorkStealingQueue {
    struct QueueArray {
        private var C: Int
        private var M: Int

        private var S: Vec<UnsafeAtomic<RenderJobIndex>>

        init(_ c: Int) {
            C = c
            M = c - 1
            S = Vec(count: c) { _ in UnsafeAtomic.create(0) }
        }

        func destroy() {
            for i in 0 ..< S.count {
                S[i].destroy()
            }
        }

        var capacity: Int { C }

        func push(_ i: Int, _ o: RenderJobIndex) {
            S[i & M].store(o, ordering: .relaxed)
        }

        func pop(_ i: Int) -> RenderJobIndex {
            S[i & M].load(ordering: .relaxed)
        }
    }

    private var _top = UnsafeAtomic<Int>.create(0)
    private var _bottom = UnsafeAtomic<Int>.create(0)
    private var _array: QueueArray

    /// constructs the queue with a given capacity
    ///
    /// capacity the capacity of the queue (must be power of 2)
    public init(capacity c: Int = 1024) {
        // assert(c && (!(c & (c-1))))
        _array = QueueArray(c)
    }

    deinit {
        _top.destroy()
        _bottom.destroy()
        _array.destroy()
    }

    /// queries if the queue is empty at the time of this call
    public var isEmpty: Bool {
        let b = _bottom.load(ordering: .relaxed)
        let t = _top.load(ordering: .relaxed)
        return b <= t
    }

    /// queries the number of items at the time of this call
    public var count: Int {
        let b = _bottom.load(ordering: .relaxed)
        let t = _top.load(ordering: .relaxed)
        return b >= t ? b - t : 0
    }

    /// queries the capacity of the queue
    public var capacity: Int {
        _array.capacity
    }

    /// inserts an item to the queue
    ///
    /// Only the owner thread can insert an item to the queue.
    /// The operation can trigger the queue to resize its capacity
    /// if more space is required.
    public func push(_ o: RenderJobIndex) {
        let b = _bottom.load(ordering: .relaxed)
        let t = _top.load(ordering: .acquiring)

        // queue is full
        if _array.capacity - 1 < (b - t) {
            fatalError("Queue full. We should know statically the max size of the queue.")
        }

        _array.push(b, o)
        atomicMemoryFence(ordering: .releasing)
        _bottom.store(b + 1, ordering: .relaxed)
    }

    /// pops out an item from the queue
    ///
    /// Only the owner thread can pop out an item from the queue.
    /// The return can be a @std_nullopt if this operation failed (empty queue).
    public func pop() -> RenderJobIndex? {
        let b = _bottom.load(ordering: .relaxed) - 1
        _bottom.store(b, ordering: .relaxed)
        atomicMemoryFence(ordering: .sequentiallyConsistent)
        let t = _top.load(ordering: .relaxed)

        var item: RenderJobIndex?

        if t <= b {
            item = _array.pop(b)
            if t == b {
                // the last item just got stolen
                let (exchanged, _) = _top.compareExchange(expected: t,
                                                          desired: t + 1,
                                                          successOrdering: .sequentiallyConsistent,
                                                          failureOrdering: .relaxed)
                if !exchanged {
                    item = nil
                }
                _bottom.store(b + 1, ordering: .relaxed)
            }
        } else {
            _bottom.store(b + 1, ordering: .relaxed)
        }

        return item
    }

    /// steals an item from the queue
    ///
    /// Any threads can try to steal an item from the queue.
    /// The return can be nil if this operation failed (not necessary empty).
    public func steal() -> RenderJobIndex? {
        let t = _top.load(ordering: .acquiring)
        atomicMemoryFence(ordering: .sequentiallyConsistent)
        let b = _bottom.load(ordering: .acquiring)

        var item: RenderJobIndex?

        if t < b {
            item = _array.pop(t)

            let (exchanged, _) = _top.compareExchange(expected: t,
                                                      desired: t + 1,
                                                      successOrdering: .sequentiallyConsistent,
                                                      failureOrdering: .relaxed)

            if !exchanged {
                return nil
            }
        }

        return item
    }
}

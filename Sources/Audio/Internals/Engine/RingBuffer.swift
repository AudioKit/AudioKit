// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import Atomics

/// Lock-free FIFO.
public class RingBuffer<T> {

    private var _head = ManagedAtomic<Int32>(0)
    private var _tail = ManagedAtomic<Int32>(0)
    private var _buffer: UnsafeMutableBufferPointer<T>

    public init() {
        _buffer = .allocate(capacity: 1024)
    }

    deinit {
        _buffer.deallocate()
    }

    private func next(_ current: Int32) -> Int32 {
        (current+1) % Int32(_buffer.count)
    }

    /// Push a single element
    /// - Parameter value: value to be pushed
    /// - Returns: whether the value could be pushed (or not enough space)
    public func push(_ value: T) -> Bool {
        let head = _head.load(ordering: .relaxed)
        let next_head = next(head)
        if next_head == _tail.load(ordering: .acquiring) {
            return false
        }
        _buffer[Int(head)] = value
        _head.store(next_head, ordering: .releasing)
        return true
    }

    private func write_available(_ head: Int32, _ tail: Int32) -> Int32 {
        var ret = tail - head - 1;
        if head >= tail {
            ret += Int32(_buffer.count)
        }
        return ret
    }

    private func read_available(_ head: Int32, _ tail: Int32) -> Int32 {
        if head >= tail {
            return head - tail
        }
        return head + Int32(_buffer.count) - tail
    }

    /// Push elements from a buffer.
    /// - Parameter ptr: Buffer from which to read elements.
    /// - Returns: whether the elements could be pushed
    public func push(from ptr: UnsafeBufferPointer<T>) -> Bool {

        let head = _head.load(ordering: .relaxed)
        let tail = _tail.load(ordering: .acquiring)
        let avail = write_available(head, tail)

        if avail < ptr.count {
            return false
        }

        for i in 0..<ptr.count {
            _buffer[(Int(head) + i) % _buffer.count] = ptr[i]
        }

        let next_head = (Int(head) + ptr.count) % _buffer.count;
        _head.store(Int32(next_head), ordering: .releasing);
        return true
    }

    public func push(interleaving leftPtr: UnsafeBufferPointer<T>, and rightPtr: UnsafeBufferPointer<T>) -> Bool {
        assert(leftPtr.count == rightPtr.count)

        var head = _head.load(ordering: .relaxed)
        let tail = _tail.load(ordering: .acquiring)
        let avail = write_available(head, tail)

        if avail < (leftPtr.count * 2) {
            return false
        }

        for i in 0..<leftPtr.count {
            _buffer[Int(head)] = leftPtr[i]
            head = (head + 1) % Int32(_buffer.count)
            _buffer[Int(head)] = rightPtr[i]
            head = (head + 1) % Int32(_buffer.count)
        }

        _head.store(Int32(head), ordering: .releasing)
        return true
    }

    /// Pop off a single element
    /// - Returns: The element or nil if no elements were available.
    public func pop() -> T? {

        let tail = _tail.load(ordering: .relaxed);
        if tail == _head.load(ordering: .acquiring) {
            return nil
        }

        let value = _buffer[Int(tail)]
        _tail.store(next(tail), ordering: .releasing)

        return value
    }

    /// Pop elements into a buffer.
    /// - Parameter ptr: Buffer to store elements.
    /// - Returns: whether the elements could be popped
    public func pop(to ptr: UnsafeMutableBufferPointer<T>) -> Bool {

        let head = _head.load(ordering: .acquiring)
        var tail = _tail.load(ordering: .relaxed)

        let avail = read_available(head, tail)

        if avail < ptr.count {
            return false
        }

        for i in 0..<ptr.count {
            ptr[i] = _buffer[Int(tail)]
            tail = (tail + 1) % Int32(_buffer.count)
        }

        _tail.store(tail, ordering: .releasing)
        return true
    }
}

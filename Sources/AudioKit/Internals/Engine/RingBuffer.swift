// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

// Just in case we can't figure out how to send things to the audio
// thread over MIDI.
#if false
import Atomics

/// Lock-free FIFO based on TPCircularBuffer without the fancy VM mirroring stuff.
class RingBuffer<T> {

    var head: Int32 = 0
    var tail: Int32 = 0
    var fillCount = ManagedAtomic<Int32>(0)
    var buffer: UnsafeMutableBufferPointer<T>

    init() {
        buffer = .allocate(capacity: 1024)
    }

    deinit {
        buffer.deallocate()
    }

    /// Push a single element
    /// - Parameter value: value to be pushed
    /// - Returns: whether the value could be pushed (or not enough space)
    func push(_ value: T) -> Bool {
        if Int32(buffer.count) - fillCount.load(ordering: .relaxed) > 0 {
            buffer[Int(head)] = value
            head = (head + 1) % Int32(buffer.count)
            fillCount.wrappingIncrement(ordering: .relaxed)
            return true
        }
        return false
    }

    /// Push elements from a buffer.
    /// - Parameter ptr: Buffer from which to read elements.
    /// - Returns: whether the elements could be pushed
    func push(from ptr: UnsafeBufferPointer<T>) -> Bool {
        if Int32(buffer.count) - fillCount.load(ordering: .relaxed) >= ptr.count {
            for i in 0..<ptr.count {
                buffer[Int(head)] = ptr[i]
                head = (head + 1) % Int32(buffer.count)
            }
            fillCount.wrappingIncrement(by: Int32(ptr.count), ordering: .relaxed)
            return true
        }
        return false
    }

    /// Pop off a single element
    /// - Returns: The element or nil if no elements were available.
    func pop() -> T? {
        if fillCount.load(ordering: .relaxed) > 0 {
            let index = Int32(tail)
            tail = (tail + 1) % Int32(buffer.count)
            fillCount.wrappingDecrement(ordering: .relaxed)
            return buffer[Int(index)]
        }
        return nil
    }

    /// Pop elements into a buffer.
    /// - Parameter ptr: Buffer to store elements.
    /// - Returns: whether the elements could be popped
    func pop(to ptr: UnsafeMutableBufferPointer<T>) -> Bool {
        if fillCount.load(ordering: .relaxed) >= ptr.count {
            for i in 0..<ptr.count {
                ptr[i] = buffer[Int(tail)]
                tail = (tail + 1) % Int32(buffer.count)
            }
            fillCount.wrappingDecrement(by: Int32(ptr.count), ordering: .relaxed)
            return true
        }
        return false
    }
}

#endif

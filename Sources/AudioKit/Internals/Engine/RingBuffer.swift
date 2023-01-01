// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import Atomics

/// Lock-free FIFO based on TPCircularBuffer without the fancy VM mirroring stuff.
public class RingBuffer<T> {

    var head: Int32 = 0
    var tail: Int32 = 0
    var fillCount: Int32 = 0
    var buffer: UnsafeMutableBufferPointer<T>

    public init() {
        buffer = .allocate(capacity: 1024)
    }

    deinit {
        buffer.deallocate()
    }

    /// Push a single element
    /// - Parameter value: value to be pushed
    /// - Returns: whether the value could be pushed (or not enough space)
    public func push(_ value: T) -> Bool {
        assert(_isPOD(type(of: value)))
        if Int32(buffer.count) - fillCount > 0 {
            buffer[Int(head)] = value
            head = (head + 1) % Int32(buffer.count)
            OSAtomicIncrement32(&fillCount)
            return true
        }
        return false
    }

    /// Push elements from a buffer.
    /// - Parameter ptr: Buffer from which to read elements.
    /// - Returns: whether the elements could be pushed
    public func push(from ptr: UnsafeBufferPointer<T>) -> Bool {
        if Int32(buffer.count) - fillCount >= ptr.count {
            for i in 0..<ptr.count {
                buffer[Int(head)] = ptr[i]
                head = (head + 1) % Int32(buffer.count)
            }
            OSAtomicAdd32(Int32(ptr.count), &fillCount)
            return true
        }
        return false
    }

    /// Pop off a single element
    /// - Returns: The element or nil if no elements were available.
    public func pop() -> T? {
        if fillCount > 0 {
            let index = Int32(tail)
            tail = (tail + 1) % Int32(buffer.count)
            OSAtomicDecrement32(&fillCount)
            return buffer[Int(index)]
        }
        return nil
    }

    /// Pop elements into a buffer.
    /// - Parameter ptr: Buffer to store elements.
    /// - Returns: whether the elements could be popped
    public func pop(to ptr: UnsafeMutableBufferPointer<T>) -> Bool {
        if fillCount >= ptr.count {
            for i in 0..<ptr.count {
                ptr[i] = buffer[Int(tail)]
                tail = (tail + 1) % Int32(buffer.count)
            }
            OSAtomicAdd32(-Int32(ptr.count), &fillCount)
            return true
        }
        return false
    }
}

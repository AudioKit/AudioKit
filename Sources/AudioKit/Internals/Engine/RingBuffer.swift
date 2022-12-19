// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

class RingBuffer<T> {

    var head: Int32 = 0
    var tail: Int32 = 0
    var fillCount: Int32 = 0
    var buffer: UnsafeMutableBufferPointer<T>

    init() {
        buffer = .allocate(capacity: 1024)
    }

    deinit {
        buffer.deallocate()
    }

    func push(_ value: T) -> Bool {
        if Int32(buffer.count) - fillCount > 0 {
            buffer[Int(head)] = value
            head = (head + 1) % Int32(buffer.count)
            OSAtomicIncrement32(&fillCount)
            return true
        }
        return false
    }

    func push(_ ptr: UnsafeBufferPointer<T>) -> Bool {
        if Int32(buffer.count) - fillCount > ptr.count {
            for i in 0..<ptr.count {
                buffer[Int(head)] = ptr[i]
                head = (head + 1) % Int32(buffer.count)
            }
            OSAtomicAdd32(Int32(ptr.count), &fillCount)
            return true
        }
        return false
    }

    func pop() -> T? {
        if fillCount > 0 {
            let index = Int32(tail)
            tail = (tail + 1) % Int32(buffer.count)
            OSAtomicDecrement32(&fillCount)
            return buffer[Int(index)]
        }
        return nil
    }

    func pop(_ ptr: UnsafeMutableBufferPointer<T>) -> Bool {
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

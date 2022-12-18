// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

struct RingBuffer<T> {

    var head: Int32 = 0
    var tail: Int32 = 0
    var fillCount: Int32 = 0
    var buffer: UnsafeMutableBufferPointer<T>

    init() {
        buffer = .allocate(capacity: 1024)
    }

    mutating func push(_ value: T) -> Bool {
        if Int32(buffer.count) - fillCount > 0 {
            buffer[Int(head)] = value
            head = (head + 1) % Int32(buffer.count)
            OSAtomicAdd32(1, &fillCount)
            return true
        }
        return false
    }

    mutating func pop() -> T? {
        if fillCount > 0 {
            tail = (tail + 1) % Int32(buffer.count)
            OSAtomicAdd32(-1, &fillCount)
            return buffer[Int(tail)]
        }
        return nil
    }
}

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public protocol DefaultInit {
    init()
}

/// Fixed size vector.
class Vec<T> where T: DefaultInit {

    private var storage: UnsafeMutableBufferPointer<T>

    init(count: Int) {
        storage = UnsafeMutableBufferPointer<T>.allocate(capacity: count)
        _ = storage.initialize(from: (0..<count).map { _ in T() })
    }

    deinit {
        storage.baseAddress?.deinitialize(count: count)
        storage.deallocate()
    }

    var count: Int { storage.count }

    subscript(index:Int) -> T {
        get {
            return storage[index]
        }
        set(newElm) {
            storage[index] = newElm
        }
    }
}

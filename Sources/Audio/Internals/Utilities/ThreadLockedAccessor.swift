//  ThreadLockedAccessor.swift
//  MIDIKit
//  Created by Steffan Andrews on 2020-12-20.

import Darwin
import Utilities

/// A property wrapper that ensures atomic access to a value, meaning thread-safe with implicit serial read/write access.
///
/// Multiple read accesses can potentially read at the same time, just not during a write.
///
/// By using `pthread` to do the locking, this safer than using a `DispatchQueue/barrier` as there isn't a chance of priority inversion.
///
/// By using `_modify { }` instead of `set { }` for mutation, direct and exclusive mutability is provided. In cases where get-then-set semantics may otherwise exist on wrapped value types (such as with subscript setters on `Array` or `Dictionary`), these remain stable during concurrent access by assuring the get and set happen in a single operation, and also provides a performance improvement.
@propertyWrapper
public final class ThreadLockedAccessor<T> {
    private var value: T
    private let lock: ThreadLock = RWThreadLock()

    /// Initialize
    public init(wrappedValue value: T) {
        self.value = value
    }

    /// Wrapped value
    public var wrappedValue: T {
        get {
            lock.readLock()
            defer { self.lock.unlock() }
            return value
        }
        _modify {
            lock.writeLock()
            yield &value
            lock.unlock()
        }
    }
}

/// Defines a basic signature to which all locks will conform. Provides the basis for atomic access to stuff.
private protocol ThreadLock {
    init()

    /// Lock a resource for writing. So only one thing can write, and nothing else can read or write.
    func writeLock()

    /// Lock a resource for reading. Other things can also lock for reading at the same time, but nothing else can write at that time.
    func readLock()

    /// Unlock a resource
    func unlock()
}

private final class RWThreadLock: ThreadLock {
    private var lock = pthread_rwlock_t()

    init() {
        guard pthread_rwlock_init(&lock, nil) == 0 else {
            Log("Unable to initialize the lock")
            return
        }
    }

    deinit {
        pthread_rwlock_destroy(&lock)
    }

    func writeLock() {
        pthread_rwlock_wrlock(&lock)
    }

    func readLock() {
        pthread_rwlock_rdlock(&lock)
    }

    func unlock() {
        pthread_rwlock_unlock(&lock)
    }
}

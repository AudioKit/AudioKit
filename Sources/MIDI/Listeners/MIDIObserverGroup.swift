// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// Observer protocol
public protocol ObserverProtocol {
    /// Equality test
    /// - Parameter listener: Another listener
    func isEqualTo(_ listener: ObserverProtocol) -> Bool
}

extension ObserverProtocol {
    /// Equality test
    /// - Parameter listener: Another listener
    func isEqualTo(_ listener: ObserverProtocol) -> Bool {
        self == listener
    }
}

func == (lhs: ObserverProtocol, rhs: ObserverProtocol) -> Bool {
    lhs.isEqualTo(rhs)
}

class MIDIObserverGroup<P> where P: ObserverProtocol {
    var observers: [P] = []

    /// Add an observer that conforms to the observer protocol
    /// - Parameter observer: Object conforming to the observer protocol
    public func addObserver(_ observer: P) {
        observers.append(observer)
    }

    /// Remove an observer that conforms to the observer protocol
    /// - Parameter observer: Object conforming to the observer protocol
    public func removeObserver(_ observer: P) {
        observers.removeAll { (anObserver: P) -> Bool in
            anObserver.isEqualTo(observer)
        }
    }

    /// Remove all observers
    public func removeAllObserver(_ observer: P) {
        observers.removeAll()
    }

    /// Do something to all observers
    /// - Parameter block: Block to call on each observer
    public func forEachObserver(_ block: (P) -> Void ) {
        for observer in observers { block(observer) }
    }
}

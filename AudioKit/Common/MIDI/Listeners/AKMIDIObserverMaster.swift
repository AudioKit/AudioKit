//
//  AKMIDIObserverMaster.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/23/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

public protocol ObserverProtocol {
    func isEqualTo(_ listener: ObserverProtocol) -> Bool
}

extension ObserverProtocol {
    func isEqualTo(_ listener: ObserverProtocol) -> Bool {
        return self == listener
    }
}

func == (lhs: ObserverProtocol, rhs: ObserverProtocol) -> Bool {
    return lhs.isEqualTo(rhs)
}

class AKMIDIObserverMaster<P> where P: ObserverProtocol {

    var observers: [P] = []

    public func addObserver(_ observer: P) {
        observers.append(observer)
    }

    public func removeObserver(_ observer: P) {
        observers.removeAll { (anObserver: P) -> Bool in
            return anObserver.isEqualTo(observer)
        }
    }

    public func removeAllObserver(_ observer: P) {
        observers.removeAll()
    }

    public func forEachObserver(_ block: (P) -> Void ) {
        observers.forEach { (observer) in
            block(observer)
        }
    }
}

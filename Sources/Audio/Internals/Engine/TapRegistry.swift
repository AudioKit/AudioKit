// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

class TapRegistry: @unchecked Sendable {

    struct WeakTap {
        weak var tap: Tap?

        init(tap: Tap?) {
            self.tap = tap
        }
    }

    let tapRegistryLock = NSLock()

    var tapRegistry: [ObjectIdentifier: [WeakTap]] = [:]

    func getTapsFor(node: Node) -> [Tap] {
        tapRegistryLock.withLock {
            (tapRegistry[ObjectIdentifier(node)] ?? []).compactMap { $0.tap }
        }
    }

    func add(tap: Tap, for node: Node) {
        tapRegistryLock.withLock {
            if tapRegistry.keys.contains(ObjectIdentifier(node)) {
                tapRegistry[ObjectIdentifier(node)]?.append(WeakTap(tap: tap))
            } else {
                tapRegistry[ObjectIdentifier(node)] = [WeakTap(tap: tap)]
            }
        }
    }

    static let shared = TapRegistry()
}

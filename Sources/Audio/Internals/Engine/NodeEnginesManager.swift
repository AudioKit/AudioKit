// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

class NodeEnginesManager: @unchecked Sendable {

    struct WeakEngineAU {
        weak var engine: EngineAudioUnit?
    }

    private let nodeEnginesLock = NSLock()

    private var nodeEngines: [ObjectIdentifier: WeakEngineAU] = [:]

    func getEngine(for node: Node) -> EngineAudioUnit? {
        nodeEnginesLock.withLock {
            nodeEngines[.init(node)]?.engine
        }
    }

    func set(engine: EngineAudioUnit, for node: Node) {
        nodeEnginesLock.withLock {
            nodeEngines[.init(node)] = .init(engine: engine)
        }
    }

    static let shared = NodeEnginesManager()
}

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFAudio

/// Describes a way to disconnect a node from another node
public enum DisconnectStrategy {
    /// Recursively traverse node chain and disconnect
    /// This strategy will keep connections from downstream nodes
    /// to nodes that are not in current disconnect path
    /// For example:
    /// Mixer1
    ///          ---> Node1
    /// Mixer2
    /// When disconnecting Node1 from Mixer1, Mixer2's connection to Node1
    /// will be preserved
    case recursive
    /// Recursively traverse node chain and deatach nodes
    /// Audio engine will automatically disconnect detached nodes
    /// This strategy will not keep any connections from downstream nodes
    /// For example:
    /// Mixer1
    ///          ---> Node1
    /// Mixer2
    /// When disconnecting Node1 from Mixer1, Mixer2's connection to Node1
    /// will not be preserved
    /// Use only when you are sure that you have only one chain path to node
    /// that you are disconnecting
    case deatach
}

extension Node {

    func disconnect(input: Node, strategy: DisconnectStrategy) {
        switch strategy {
        case .recursive: disconnectAndDetachIfLast(input: input)
        case .deatach: input.detach()
        }
    }

    func disconnectAndDetachIfLast(input: Node) {
        if let engine = avAudioNode.engine {
            let points = engine.outputConnectionPoints(for: input.avAudioNode, outputBus: 0)
            let otherConnections = points.filter { $0.node != self.avAudioNode }
            if otherConnections.isEmpty {
                // It is important to go depth first search.
                // If we first detach the current node,
                // upstream nodes will lose the connection to the engine.
                for connection in input.connections {
                    input.disconnectAndDetachIfLast(input: connection)
                }
                engine.detach(input.avAudioNode)
            } else {
                avAudioNode.disconnect(input: input.avAudioNode)
            }
        }
    }

    func detach() {
        guard let engine = avAudioNode.engine else { return }
        detach(from: engine)
    }

    func detach(from engine: AVAudioEngine) {
        engine.detach(avAudioNode)
        for connection in connections {
            connection.detach(from: engine)
        }
    }
}

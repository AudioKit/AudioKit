// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Mixer Node. Mixes a variadic list of Nodes.
public class Mixer: Node, Toggleable, NamedNode {
    /// The internal mixer node
    fileprivate var mixerAU = AVAudioMixerNode()

    /// Name of the node
    open var name = "(unset)"

    /// Output Volume (Default 1), values above 1 will have gain applied
    public var volume: AUValue = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixerAU.outputVolume = volume
        }
    }

    /// Output Pan (-1 to 1, Default 0 = center)
    public var pan: AUValue = 0 {
        didSet {
            pan = min(pan, 1)
            pan = max(pan, -1)
            mixerAU.pan = pan
        }
    }

    fileprivate var lastKnownVolume: AUValue = 1.0

    /// Determine if the mixer is serving any output or if it is stopped.
    public var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the mixer node with no inputs, to be connected later
    public init(volume: AUValue = 1.0, name: String? = nil) {
        super.init(avAudioNode: mixerAU)
        self.volume = volume
        self.name = name ?? MemoryAddress(of: self).description
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: A variadic list of Nodes
    ///
    public convenience init(_ inputs: Node..., name: String? = nil) {
        self.init(inputs.compactMap { $0 }, name: name)
    }

    // swiftlint:enable force_unwrapping

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: An array of Nodes
    ///
    public convenience init(_ inputs: [Node], name: String? = nil) {
        self.init(name: name)
        connections = inputs
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }

    /// Add input to the mixer
    /// - Parameter node: Node to add
    public func addInput(_ node: Node) {
        guard !hasInput(node) else {
            Log("🛑 Error: Node is already connected to Mixer.")
            return
        }
        connections.append(node)
        makeAVConnections()
    }

    /// Is this node already connected?
    /// - Parameter node: Node to check
    public func hasInput(_ node: Node) -> Bool {
        connections.contains(where: { $0 === node })
    }

    /// Remove input from the mixer
    /// - Parameter node: Node to remove
    public func removeInput(_ node: Node) {
        connections.removeAll(where: { $0 === node })
        avAudioNode.disconnect(input: node.avAudioNode)
    }

    /// Remove all inputs from the mixer
    public func removeAllInputs() {
        guard connections.isNotEmpty else { return }

        let nodes = connections.map { $0.avAudioNode }
        for input in nodes {
            avAudioNode.disconnect(input: input)
        }
        connections.removeAll()
    }
}

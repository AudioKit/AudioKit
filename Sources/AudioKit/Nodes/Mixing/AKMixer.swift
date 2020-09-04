// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Mixer Node. Mixes a varaiadic list of AKNodes.
public class AKMixer: AKNode, AKToggleable {
    /// The internal mixer node
    fileprivate var mixerAU = AVAudioMixerNode()

    /// Output Volume (Default 1)
    public var volume: AUValue = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixerAU.outputVolume = volume
        }
    }

    /// Output Pan (Default 0 = center)
    public var pan: AUValue = 1.0 {
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
    public init(volume: AUValue = 1.0) {
        super.init(avAudioNode: mixerAU)
        self.volume = volume
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: A variadic list of AKNodes
    ///
    public convenience init(_ inputs: AKNode...) {
        self.init(inputs.compactMap { $0 })
    }

    // swiftlint:enable force_unwrapping

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: An array of AKNodes
    ///
    public convenience init(_ inputs: [AKNode]) {
        self.init()
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

    public func addInput(_ node: AKNode) {
        if connections.contains(where: { $0 === node }) {
            AKLog("🛑 Error: Node is already connected to AKMixer.")
            return
        }
        connections.append(node)
        makeAVConnections()
    }

    public func removeInput(_ node: AKNode) {
        connections.removeAll(where: { $0 === node })
        avAudioNode.disconnect(input: node.avAudioNode)
    }
}

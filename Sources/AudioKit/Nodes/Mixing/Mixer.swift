// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// AudioKit version of Apple's Mixer Node. Mixes a variadic list of Nodes.
public class Mixer: Node, NamedNode {
    /// The internal mixer node
    fileprivate let mixerAU = AVAudioMixerNode()

    var inputs: [Node] = []

    /// Connected nodes
    public var connections: [Node] { inputs }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode

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
            pan = pan.clamped(to: -1...1)
            mixerAU.pan = pan
        }
    }

    /// Determine if the mixer is serving any output or if it is stopped.
    public var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the mixer node with no inputs, to be connected later
    public init(volume: AUValue = 1.0, name: String? = nil) {
        avAudioNode = mixerAU
        self.volume = volume
        self.name = name ?? MemoryAddress(of: self).description
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: A variadic list of Nodes
    /// - parameter name: Optional name of the mixer
    ///
    public convenience init(_ inputs: Node..., name: String? = nil) {
        self.init(inputs.compactMap { $0 }, name: name)
    }

    // swiftlint:enable force_unwrapping

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: An array of Nodes
    /// - parameter name: Optional name of the mixer
    ///
    public convenience init(_ inputs: [Node], name: String? = nil) {
        self.init(name: name)
        self.inputs = inputs
    }

    /// Add input to the mixer
    /// - Parameter node: Node to add
    public func addInput(_ node: Node) {
        guard !hasInput(node) else {
            Log("🛑 Error: Node is already connected to Mixer.")
            return
        }

        // if this mixer is empty, must initialize
        let mixerReset = mixerAU.engine?.initializeMixer(mixerAU)

        inputs.append(node)

        if let mixerReset = mixerReset {
            mixerAU.engine?.detach(mixerReset)
        }

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
        inputs.removeAll(where: { $0 === node })
        avAudioNode.disconnect(input: node.avAudioNode)
    }

    /// Remove all inputs from the mixer
    public func removeAllInputs() {
        guard connections.isNotEmpty else { return }

        let nodes = connections.map { $0.avAudioNode }
        for input in nodes {
            avAudioNode.disconnect(input: input)
        }
        inputs.removeAll()
    }

    /// Resize underlying AVAudioMixerNode input buses array to accommodate for required count of inputs.
    ///
    /// ```
    /// let desiredInputCount = 5
    /// let allowedCount = mixer.resizeInputBusesArray(requiredSize: desiredInputCount)
    ///// allowedCount is now 5 or less
    /// ```
    /// If engine has already started, underlying AVAudioMixerNode won't resize its input buses
    /// array when new input nodes are added into it, which may eventually cause a crash.
    ///
    /// Use this function to avoid that and resize input buses array manually before adding new inputs to the mixer.
    ///
    /// If the current buses array size is less than required, it will attempt to resize the array.
    /// Otherwise, no changes will be made.
    ///
    /// If engine has not yet started, you shouldn't need to use this function.
    /// - Parameter requiredSize: how many input buses you need in the mixer
    /// - Returns: new input buses array size or its current size in case it's less than required
    ///  and resize failed, or can't be done.
    public func resizeInputBusesArray(requiredSize: Int) -> Int {
        let buses = mixerAU.auAudioUnit.inputBuses
        guard buses.isCountChangeable else {
            // input buses array is not changeable
            return min(buses.count, requiredSize)
        }
        if buses.count < requiredSize {
            do {
                try buses.setBusCount(requiredSize)
                return requiredSize
            } catch _ {
                // could not resize input buses array to required size
                return buses.count
            }
        }
        // current input buses array already matches or exceeds required size
        return requiredSize
    }
}

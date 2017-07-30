//
//  AKMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AudioKit version of Apple's Mixer Node
open class AKMixer: AKNode, AKToggleable {
    /// The internal mixer node
    fileprivate var mixerAU: AVAudioMixerNode?

    /// How many inputs have been connected to this mixer in its lifespan
    private var connectionCounter: Int = 0
    
    /// Output Volume (Default 1)
    open dynamic var volume: Double = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixerAU?.outputVolume = Float(volume)
        }
    }

    fileprivate var lastKnownVolume: Double = 1.0

    /// Determine if the mixer is serving any output or if it is stopped.
    open dynamic var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the mixer node with no inputs, to be connected later
    public override init() {
        super.init()
        initialize()
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: A variadic list of AKNodes
    ///
    public init(_ inputs: AKNode?...) {
        super.init()
        initialize()
        for input in inputs {
            connect(input)
        }
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: An array of AKNodes
    ///
    public init(_ inputs: [AKNode]) {
        super.init()
        initialize()
        for input in inputs {
            connect(input)
        }
    }
    
    private func initialize() {
        mixerAU = AVAudioMixerNode()
        self.avAudioNode = mixerAU!
        AudioKit.engine.attach(self.avAudioNode)
    }

    /// Connnect another input after initialization
    ///
    /// - parameter input: AKNode to connect
    /// - parameter bus: what channel of the mixer to connect on. 
    /// If you use this it is up to your application to keep track of what inputs are in use to make sure you
    /// don't overwrite an existing channel with an active node that is active.
    open func connect(_ input: AKNode?, bus: Int? = nil) {
        guard mixerAU != nil else { return }
        
        var wasRunning = false
        if AudioKit.engine.isRunning {
            wasRunning = true
            AudioKit.stop()
        }
        
        let chan = bus != nil ? bus! : mixerAU!.nextAvailableInputBus

        if let existingInput = input {
            existingInput.connectionPoints.append(AVAudioConnectionPoint(node: mixerAU!, bus: chan))
            AudioKit.engine.connect(existingInput.avAudioNode,
                                    to: existingInput.connectionPoints,
                                    fromBus: 0,
                                    format: AudioKit.format)
            
            connectionCounter += 1
            
            AKLog("AKMixer.connect() input: \(existingInput) on bus \(chan), Mixer now has \(mixerAU!.numberOfInputs) total inputs and \(connectionCounter) recent connections.")

        }
        if wasRunning {
            AudioKit.start()
        }
        
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }

}

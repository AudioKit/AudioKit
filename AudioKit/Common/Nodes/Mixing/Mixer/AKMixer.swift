//
//  AKMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// AudioKit version of Apple's Mixer Node
public class AKMixer: AKNode, AKToggleable {
    private let mixerAU = AVAudioMixerNode()
    
    /// Output Volume (Default 1)
    public var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            mixerAU.outputVolume = Float(volume)
        }
    }
    
    private var lastKnownVolume: Double = 1.0
    
    /// Determine if the mixer is serving any output or if it is stopped.
    public var isStarted: Bool {
        return volume != 0.0
    }
    
    /// Initialize the mixer node
    ///
    /// - parameter inputs: A varaiadic list of AKNodes
    ///
    public init(_ inputs: AKNode...) {
        super.init()
        self.avAudioNode = mixerAU
        AudioKit.engine.attach(self.avAudioNode)
        for input in inputs {
            connect(input)
        }
    }
    
    /// Connnect another input after initialization
    ///
    /// - parameter input: AKNode to connect
    ///
    public func connect(_ input: AKNode) {
        var wasRunning = false
        if AudioKit.engine.isRunning {
            wasRunning = true
            AudioKit.stop()
        }
        input.connectionPoints.append(AVAudioConnectionPoint(node: mixerAU, bus: mixerAU.numberOfInputs))
        AudioKit.engine.connect(input.avAudioNode, to: input.connectionPoints, fromBus: 0, format: AudioKit.format)
        if wasRunning {
            AudioKit.start()
        }
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
}

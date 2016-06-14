//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// AudioKit version of Apple's Mixer Node
public class AKBooster: AKNode, AKToggleable {
    private let mixer = AVAudioMixerNode()

    
    /// Amplification Factor
    public var gain: Double = 1.0 {
        didSet {
            mixer.outputVolume = Float(gain)
        }
    }
    
    /// Amplification Factor in db
    public var dB: Double {
        set {
            gain  = pow(10.0, Double(newValue / 20))
        }
        get {
            return 20.0 * log10(gain)
        }
    }
    
    private var lastKnownGain: Double = 1.0
    
    /// Tells whether or not the booster is actually changing the volume of its source.
    public var isStarted: Bool {
        return gain != 1.0
    }
    
    /// Initialize this amplification node
    ///
    /// - parameter input: AKNode whose output will be amplified
    /// - parameter gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: AKNode, gain: Double = 1.0) {
            
        super.init()
        self.avAudioNode = mixer
        AudioKit.engine.attach(self.avAudioNode)
        input.addConnectionPoint(self)
            
        mixer.outputVolume = Float(gain)
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            gain = lastKnownGain
        }
    }
    
    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownGain = gain
            gain = 0
        }
    }
}

//
//  AKReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// AudioKit version of Apple's Reverb Audio Unit
public class AKReverb: AKNode, AKToggleable {
    private let reverbAU = AVAudioUnitReverb()
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    private var lastKnownMix: Double = 50
    
    /// Dry/Wet Mix (Default 50) 
    public var dryWetMix: Double = 50 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 100 {
                dryWetMix = 100
            }
            reverbAU.wetDryMix = Float(dryWetMix)
        }
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true
    
    /// Initialize the reverb node
    ///
    /// - parameter input: AKNode to reverberate
    /// - parameter dryWetMix: Percentage of processed signal (Default: 50, Minimum: 0, Maximum: 100)
    ///
    public init(var _ input: AKNode, dryWetMix: Double = 50) {
        self.dryWetMix = dryWetMix
        
        self.avAudioNode = reverbAU
        AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
        input.addConnectionPoint(self)
        
        reverbAU.wetDryMix = Float(dryWetMix)
    }
    
    /// Load an Apple Factory Preset
    public func loadFactoryPreset(preset: AVAudioUnitReverbPreset) {
        reverbAU.loadFactoryPreset(preset)
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }
        
    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
}

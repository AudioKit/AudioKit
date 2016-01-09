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
///
/// - parameter input: AKNode to reverberate
/// - parameter dryWetMix: Amount of processed signal (Default: 0.5, Minimum: 0, Maximum: 1)
///
public class AKReverb: AKNode, AKToggleable {
    private let reverbAU = AVAudioUnitReverb()
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    private var lastKnownMix: Double = 0.5
    
    /// Dry/Wet Mix (Default 0.5)
    public var dryWetMix: Double = 0.5 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 1 {
                dryWetMix = 1
            }
            reverbAU.wetDryMix = Float(dryWetMix) * 100
        }
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true
    
    /// Initialize the reverb node
    ///
    /// - parameter input: AKNode to reverberate
    /// - parameter dryWetMix: Amount of processed signal (Default: 0.5, Minimum: 0, Maximum: 1)
    ///
    public init(var _ input: AKNode, dryWetMix: Double = 0.5) {
        self.dryWetMix = dryWetMix
        
        self.avAudioNode = reverbAU
        AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
        input.addConnectionPoint(self)
        
        reverbAU.wetDryMix = Float(dryWetMix) * 100.0
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

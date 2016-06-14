//
//  AKReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
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
    public init(_ input: AKNode, dryWetMix: Double = 0.5) {
        self.dryWetMix = dryWetMix
        super.init()
        
        self.avAudioNode = reverbAU
        AudioKit.engine.attach(self.avAudioNode)
        input.addConnectionPoint(self)
        
        reverbAU.wetDryMix = Float(dryWetMix) * 100.0
    }
    
    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: AVAudioUnitReverbPreset) {
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

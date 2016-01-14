//
//  CoreVoice.swift
//  SwiftSynth
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class CoreVoice: AKVoice {

    var sineVCO1 = AKOscillator()
    var sineVCO2 = AKOscillator()
    var sawtoothVCO1 = AKSawtoothOscillator()
    var sawtoothVCO2 = AKSawtoothOscillator()
    var squareVCO1 = AKSquareWaveOscillator()
    var squareVCO2 = AKSquareWaveOscillator()
    var triangleVCO1 = AKTriangleOscillator()
    var triangleVCO2 = AKTriangleOscillator()
    var subOsc = AKOscillator()
    var fmOscillator = AKFMOscillator()
    var noise = AKPinkNoise()
    
    var vco1 = AKMixer()
    var vco2 = AKMixer()
    
    var vco12Mixer: AKDryWetMixer
    var sourceMixer = AKMixer()
    var adsr: AKAmplitudeEnvelope
    
    /// Instantiate the FM Oscillator Voice
    override init() {
        
        vco1 = AKMixer(sineVCO1, sawtoothVCO1, squareVCO1, triangleVCO1)
        vco2 = AKMixer(sineVCO2, sawtoothVCO2, squareVCO2, triangleVCO2)
        vco12Mixer = AKDryWetMixer(vco1, vco2, balance: 0.5)
        
        sourceMixer = AKMixer(vco12Mixer, fmOscillator, subOsc, noise)
        
        adsr = AKAmplitudeEnvelope(sourceMixer)
        
        super.init()
        
        avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func copy() -> AKVoice {
        let copy = CoreVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return fmOscillator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        
        sineVCO1.start()
        sineVCO2.start()
        sawtoothVCO1.start()
        sawtoothVCO2.start()
        squareVCO1.start()
        squareVCO2.start()
        triangleVCO1.start()
        triangleVCO2.start()
        subOsc.start()
        fmOscillator.start()
        noise.start()
        
        adsr.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        adsr.stop()
    }
}
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
    var noise = AKWhiteNoise()

    // Adding a mixer for every source because we want both an amplitude, set by a velocity, and an overall volume and on/off controlled by UI elements
    var sineVCO1Mixer: AKMixer
    var sineVCO2Mixer: AKMixer
    var sawtoothVCO1Mixer: AKMixer
    var sawtoothVCO2Mixer: AKMixer
    var squareVCO1Mixer: AKMixer
    var squareVCO2Mixer: AKMixer
    var triangleVCO1Mixer: AKMixer
    var triangleVCO2Mixer: AKMixer
    var subOscMixer: AKMixer
    var fmOscMixer: AKMixer
    var noiseMixer: AKMixer
    
    var vco1Mixer: AKMixer
    var vco2Mixer: AKMixer
    
    var vco12Mixer: AKDryWetMixer
    var sourceMixer: AKMixer
    var adsr: AKAmplitudeEnvelope
    
    /// Instantiate the FM Oscillator Voice
    override init() {
        
        sineVCO1Mixer = AKMixer(sineVCO1)
        sineVCO2Mixer = AKMixer(sineVCO2)
        sawtoothVCO1Mixer = AKMixer(sawtoothVCO1)
        sawtoothVCO2Mixer = AKMixer(sawtoothVCO2)
        squareVCO1Mixer = AKMixer(squareVCO1)
        squareVCO2Mixer = AKMixer(squareVCO2)
        triangleVCO1Mixer = AKMixer(triangleVCO1)
        triangleVCO2Mixer = AKMixer(triangleVCO2)
        
        vco1Mixer = AKMixer(sineVCO1Mixer, sawtoothVCO1Mixer, squareVCO1Mixer, triangleVCO1Mixer)
        vco2Mixer = AKMixer(sineVCO2Mixer, sawtoothVCO2Mixer, squareVCO2Mixer, triangleVCO2Mixer)
        vco12Mixer = AKDryWetMixer(vco1Mixer, vco2Mixer, balance: 0.5)
        
        subOscMixer = AKMixer(subOsc)
        fmOscMixer = AKMixer(fmOscillator)
        noiseMixer = AKMixer(noise)
        
        // Defaults
        vco1Mixer.volume = 0
        vco2Mixer.volume = 0
        sineVCO1Mixer.volume = 0
        sineVCO2Mixer.volume = 0
        sawtoothVCO1Mixer.volume = 1
        sawtoothVCO2Mixer.volume = 1
        squareVCO1Mixer.volume = 0
        squareVCO2Mixer.volume = 0
        triangleVCO1Mixer.volume = 0
        triangleVCO2Mixer.volume = 0
        subOscMixer.volume = 0
        fmOscMixer.volume = 0
        noiseMixer.volume = 0
        
        sourceMixer = AKMixer(vco12Mixer, fmOscMixer, subOscMixer, noiseMixer)
        
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
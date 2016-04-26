//
//  CoreVoice.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class CoreVoice: AKVoice {
    var vco1: AKMorphingOscillator
    var vco2: AKMorphingOscillator
    var subOsc = AKOscillator()
    var fmOsc  = AKFMOscillator()
    var noise  = AKWhiteNoise()

    // We'll be using these simply to control volume independent of velocity
    var vco1Mixer: AKMixer
    var vco2Mixer: AKMixer
    var subOscMixer: AKMixer
    var fmOscMixer: AKMixer
    var noiseMixer: AKMixer

    var vcoBalancer: AKDryWetMixer
    var sourceMixer: AKMixer
    var adsr: AKAmplitudeEnvelope

    /// Instantiate the FM Oscillator Voice
    override init() {
        let triangle = AKTable(.Triangle)
        let square   = AKTable(.Square)
        let sawtooth = AKTable(.Sawtooth)
        var squareWithHighPWM = AKTable()
        let size = squareWithHighPWM.values.count
        for i in 0..<size {
            if i < size / 8 {
                squareWithHighPWM.values[i] = -1.0
            } else {
                squareWithHighPWM.values[i] = 1.0
            }
        }
        vco1 = AKMorphingOscillator(waveformArray: [triangle, square, squareWithHighPWM, sawtooth])
        vco2 = AKMorphingOscillator(waveformArray: [triangle, square, squareWithHighPWM, sawtooth])

        vco1Mixer   = AKMixer(vco1)
        vco2Mixer   = AKMixer(vco2)
        subOscMixer = AKMixer(subOsc)
        fmOscMixer  = AKMixer(fmOsc)
        noiseMixer  = AKMixer(noise)

        // Default non-VCO's off
        subOscMixer.volume = 0
        fmOscMixer.volume  = 0
        noiseMixer.volume  = 0

        vcoBalancer = AKDryWetMixer(vco1Mixer, vco2Mixer, balance: 0.5)

        sourceMixer = AKMixer(vcoBalancer, fmOscMixer, subOscMixer, noiseMixer)

        adsr = AKAmplitudeEnvelope(sourceMixer)

        super.init()

        avAudioNode = adsr.avAudioNode
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = CoreVoice()
        return copy
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return fmOsc.isPlaying
    }

    /// Function to start, play, or activate the node, all do the same thing
    override func start() {

        // Do not automatically start the VCOs because the logic about that is higher up
        subOsc.start()
        fmOsc.start()
        noise.start()

        adsr.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        adsr.stop()
    }
}

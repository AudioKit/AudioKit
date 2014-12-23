//
//  HarmonizerInstrument.swift
//  SwiftHarmonizer
//
//  Created by Nicholas Arner on 10/7/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

class HarmonizerInstrument: AKInstrument {
    
    // INSTRUMENT DEFINITION ===================================================
    
    override init() {
        super.init()
        
        let microphone: AKAudioInput = AKAudioInput ()
        connect (microphone)
        
        let fsig1 = AKFSignalFromMonoAudio(
            audioSource: microphone,
            fftSize: 2048.ak,
            overlap: 256.ak,
            windowType: AKFSignalFromMonoAudioWindowType.VonHann,
            windowFilterSize: 2048.ak)
        
        connect(fsig1)
        
        let fsig2 = AKScaledFSignal(
            input: fsig1,
            frequencyRatio: 2.ak,
            formantRetainMethod: AKScaledFSignalFormantRetainMethod.LifteredCepstrum,
            amplitudeRatio: nil,
            cepstrumCoefficients: nil
        )
        connect(fsig2)
        
        let fsig3 = AKScaledFSignal(
            input: fsig1,
            frequencyRatio: 2.ak,
            formantRetainMethod: AKScaledFSignalFormantRetainMethod.LifteredCepstrum,
            amplitudeRatio: nil,
            cepstrumCoefficients: nil
        )
        connect (fsig3)
        
        let fsig4 = AKFSignalMix(input1: fsig2, input2: fsig3)
        connect(fsig4)
        
        let a1 = AKAudioFromFSignal(source: fsig4)
        connect(a1)
        connect(AKAudioOutput(audioSource: a1))
    }
}
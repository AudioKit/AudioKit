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
        
        let microphoneFFT = AKFSignalFromMonoAudio(
            audioSource: microphone,
            fftSize: 2048.ak,
            overlap: 256.ak,
            windowType: AKFSignalFromMonoAudioWindowType.VonHann,
            windowFilterSize: 2048.ak)
        
        connect(microphoneFFT)
        
        let scaledFFT = AKScaledFSignal(
            input: microphoneFFT,
            frequencyRatio: 2.ak,
            formantRetainMethod: AKScaledFSignalFormantRetainMethod.LifteredCepstrum,
            amplitudeRatio: nil,
            cepstrumCoefficients: nil
        )
        connect(scaledFFT)
        
//        let fsig3 = AKScaledFSignal(
//            input: microphoneFFT,
//            frequencyRatio: 2.ak,
//            formantRetainMethod: AKScaledFSignalFormantRetainMethod.LifteredCepstrum,
//            amplitudeRatio: nil,
//            cepstrumCoefficients: nil
//        )
//        connect (fsig3)
        
        let mixedFFT = AKFSignalMix(input1: microphoneFFT, input2: scaledFFT)
        connect(mixedFFT)
        
        let audioOutput = AKAudioFromFSignal(source: mixedFFT)
        connect(audioOutput)
        connect(AKAudioOutput(audioSource: audioOutput))
    }
}
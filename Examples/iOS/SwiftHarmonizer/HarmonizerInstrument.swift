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
        
        let microphone: AKAudioInput = AKAudioInput()
        connect (microphone)
        
        let microphoneFFT = AKFFT(
            input: microphone,
            fftSize: 2048.ak,
            overlap: 256.ak,
            windowType: AKFFTWindowType.VonHann,
            windowFilterSize: 2048.ak
        )
        connect(microphoneFFT)
        
        let scaledFFT = AKScaledFFT(
            signal: microphoneFFT,
            frequencyRatio: 2.ak,
            formantRetainMethod: AKScaledFFTFormantRetainMethod.LifteredCepstrum,
            amplitudeRatio: 2.ak,
            cepstrumCoefficients: nil
        )
        connect(scaledFFT)
    
        let mixedFFT = AKMixedFFT(signal1: microphoneFFT, signal2: scaledFFT)
        connect(mixedFFT)
        
        let audioOutput = AKResynthesizedAudio(signal: mixedFFT)
        connect(audioOutput)
        connect(AKAudioOutput(audioSource: audioOutput))
    }
}
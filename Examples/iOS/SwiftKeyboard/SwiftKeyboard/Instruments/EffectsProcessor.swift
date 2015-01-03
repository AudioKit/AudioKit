//
//  EffectsProcessor.swift
//  SwiftKeyboard
//
//  Created by Aurelius Prochazka on 11/28/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

class EffectsProcessor: AKInstrument {

    // Instrument Properties
    var feedbackLevel  = AKInstrumentProperty(value: 0.0, minimum: 0.0, maximum: 1.0)
    
    init(audioSource: AKAudio) {
        
        super.init()

        // Instrument Properties
        addProperty(feedbackLevel)

        // Instrument Definition
        let reverb = AKReverb(
            input: audioSource,
            feedback: feedbackLevel,
            cutoffFrequency: 4000.ak
        )
        connect(reverb)
        
        let leftMix = AKMixedAudio (
            signal1: reverb.leftOutput,
            signal2: audioSource,
            balance: 0.5.ak)
        connect(leftMix)

        let rightMix = AKMixedAudio (
            signal1: reverb.rightOutput,
            signal2: audioSource,
            balance: 0.5.ak)
        connect(rightMix)
        
        connect(AKAudioOutput(leftAudio: leftMix, rightAudio: rightMix))
            
        resetParameter(audioSource)
    }
}

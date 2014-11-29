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
            audioSource: audioSource,
            feedbackLevel: feedbackLevel,
            cutoffFrequency: 4000.ak
        )
        connect(reverb)
        
        connect(AKAudioOutput(stereoAudioSource: reverb))
            
        resetParameter(audioSource)
    }
}

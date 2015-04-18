//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/808loop.wav"
        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio)

        let stereoImpulse = "AKSoundFiles.bundle/Sounds/shortpianohits.aif"

        let dishConvolution  = AKStereoConvolution(
            input: mono.scaledBy(0.5.ak),
            impulseResponseFilename: stereoImpulse
        )
        setStereoAudioOutput(dishConvolution)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))

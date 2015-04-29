//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Nick Arner on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"
        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let azimuth = AKLine(
            firstPoint:  0.ak,
            secondPoint: 720.ak,
            durationBetweenPoints: testDuration.ak
        )

        let binauralAudio = AK3DBinauralAudio(input: audioSource)
        binauralAudio.azimuth = azimuth

        enableParameterLog(
            "Azimuth = ",
            parameter: azimuth,
            timeInterval:0.1
        )

        setAudioOutput(binauralAudio)

        resetParameter(audioSource)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)

AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

processor.play()
instrument.play()


NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))

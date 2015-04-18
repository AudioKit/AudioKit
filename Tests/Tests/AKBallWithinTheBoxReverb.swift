//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 4.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "AKSoundFiles.bundle/Sounds/808Loop.wav"

        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio);
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let xLocation = AKLine(
            firstPoint: 1.ak,
            secondPoint: 6.ak,
            durationBetweenPoints: testDuration.ak
        )

        let yLocation = AKLine(
            firstPoint: 1.ak,
            secondPoint: 4.ak,
            durationBetweenPoints: testDuration.ak
        )

        let zLocation = AKLine(
            firstPoint: 1.ak,
            secondPoint: 3.ak,
            durationBetweenPoints: testDuration.ak
        )

        enableParameterLog("X Location = ", parameter: xLocation, timeInterval:0.3)
        enableParameterLog("Y Location = ", parameter: yLocation, timeInterval:0.3)
        enableParameterLog("Z Location = ", parameter: zLocation, timeInterval:0.3)

        let ballWithinTheBoxReverb = AKBallWithinTheBoxReverb(input: audioSource)
        ballWithinTheBoxReverb.xLocation = xLocation
        ballWithinTheBoxReverb.yLocation = yLocation
        ballWithinTheBoxReverb.zLocation = zLocation
        ballWithinTheBoxReverb.diffusion = 0.0.ak

        let mix = AKMix(
            input1: audioSource,
            input2: AKMix(monoAudioFromStereoInput: ballWithinTheBoxReverb),
            balance: 0.1.ak
        )

        setAudioOutput(mix)

        resetParameter(audioSource)
    }
}
AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)

AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

processor.play()
instrument.playNote(AKNote(), afterDelay: 0.5)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))

//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMixedAudio(signal1: audio.leftOutput, signal2: audio.rightOutput, balance: 0.5.ak)
        connect(mono)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}
class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let feedback = AKLine(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: 11.ak)
        connect(feedback)

        let cutoffFrequency = AKLine(firstPoint: 100.ak, secondPoint: 10000.ak, durationBetweenPoints: 11.ak)
        connect(cutoffFrequency)

        let operation = AKReverb(audioSourceLeftChannel: audioSource, audioSourceRightChannel: audioSource)
        operation.feedback = 0.95.ak
        operation.cutoffFrequency = cutoffFrequency
        connect(operation)

        connect(AKAudioOutput(stereoAudioSource:operation))
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(10)

processor.play()
instrument.play()


while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")

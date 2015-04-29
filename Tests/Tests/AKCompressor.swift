//
//  main.swift
//  AudioKit
//
//  Customized by Nick Arner and Aurelius Prochazka on 12/27/14.
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

        let compressionRatio = AKLine(
            firstPoint:  0.5.ak,
            secondPoint: 2.ak,
            durationBetweenPoints: testDuration.ak
        )

        let attackTime = AKLine(
            firstPoint:  0.ak,
            secondPoint: 1.ak,
            durationBetweenPoints: testDuration.ak
        )

        let compressor = AKCompressor(input: audioSource, controllingInput: audioSource)
        compressor.compressionRatio = compressionRatio
        compressor.attackTime = attackTime

        let balance = AKBalance(input: compressor, comparatorAudioSource: audioSource)

        enableParameterLog(
            "Compression Ratio = ",
            parameter: compressor.compressionRatio,
            timeInterval:0.2
        )

        enableParameterLog(
            "Attack Time = ",
            parameter: compressor.attackTime,
            timeInterval:0.2
        )
        setAudioOutput(balance)

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

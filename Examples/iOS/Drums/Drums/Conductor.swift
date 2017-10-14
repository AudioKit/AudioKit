//
//  Conductor.swift
//  Drums
//
//  Created by Aurelius Prochazka on 8/13/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit

class Conductor {
    static let sharedInstance = Conductor()
    let drums = AKSampler()

    init() {

        AudioKit.output = drums
        AudioKit.start()

        do {
            let bassDrumFile = try AKAudioFile(readFileName: "Samples/Drums/bass_drum_C1.wav")
            let clapFile = try AKAudioFile(readFileName: "Samples/Drums/clap_D#1.wav")
            let closedHiHatFile = try AKAudioFile(readFileName: "Samples/Drums/closed_hi_hat_F#1.wav")
            let hiTomFile = try AKAudioFile(readFileName: "Samples/Drums/hi_tom_D2.wav")
            let loTomFile = try AKAudioFile(readFileName: "Samples/Drums/lo_tom_F1.wav")
            let midTomFile = try AKAudioFile(readFileName: "Samples/Drums/mid_tom_B1.wav")
            let openHiHatFile = try AKAudioFile(readFileName: "Samples/Drums/open_hi_hat_A#1.wav")
            let snareDrumFile = try AKAudioFile(readFileName: "Samples/Drums/snare_D1.wav")

            try drums.loadAudioFiles([bassDrumFile,
                                      clapFile,
                                      closedHiHatFile,
                                      hiTomFile,
                                      loTomFile,
                                      midTomFile,
                                      openHiHatFile,
                                      snareDrumFile])

        } catch {
            AKLog("Files Didn't Load")
        }

    }
}

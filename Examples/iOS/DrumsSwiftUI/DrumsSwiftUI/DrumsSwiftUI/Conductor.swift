//
//  Conductor.swift
//  DrumsSwiftUI
//
//  Created by Matthias Frick on 11/09/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import AudioKit
import Combine

struct DrumSample {
    var fileName: String
    var midiNote: Int
    var audioFile: AKAudioFile?

    init(_ sampleFileName: String, note: Int) {
        fileName = sampleFileName
        midiNote = note
        do {
            audioFile = try AKAudioFile(readFileName: fileName)
        } catch {
            AKLog("Could not load: $fileName")
        }
    }
}

class Conductor: ObservableObject {
    // Mark Published so View updates label on changes
    @Published private(set) var lastPlayed: String = "None"

    let drumSamplesFiles: [DrumSample] =
    [
        DrumSample("Samples/Drums/bass_drum_C1.wav", note: 24),
        DrumSample("Samples/Drums/closed_hi_hat_F#1.wav", note: 26),
        DrumSample("Samples/Drums/hi_tom_D2.wav", note: 30),
        DrumSample("Samples/Drums/lo_tom_F1.wav", note: 34),
        DrumSample("Samples/Drums/mid_tom_B1.wav", note: 29),
        DrumSample("Samples/Drums/open_hi_hat_A#1.wav", note: 35),
        DrumSample("Samples/Drums/snare_D1.wav", note: 24),
        DrumSample("Samples/Drums/bass_drum_C1.wav", note: 38),
        DrumSample("Samples/Drums/bass_drum_C1.wav", note: 24)
    ]

    let drums = AKAppleSampler()

    func playPad(padNumber: Int) {
        try? drums.play(noteNumber: MIDINoteNumber(drumSamplesFiles[padNumber].midiNote))
        let fileName = drumSamplesFiles[padNumber].fileName
        lastPlayed = fileName.components(separatedBy: "/").last!
    }

    init() {
        AudioKit.output = drums
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        do {
          let files = drumSamplesFiles.map {
            $0.audioFile!
          }
          try drums.loadAudioFiles(files)

        } catch {
            AKLog("Files Didn't Load")
        }
    }
}

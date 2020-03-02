//
//  Conductor.swift
//  Drums
//
//  Created by Matthias Frick on 11/09/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import Combine

struct DrumSample {
  var name: String
  var fileName: String
  var midiNote: Int
  var audioFile: AKAudioFile?
  var color = AKStylist.sharedInstance.nextColor

  init(_ prettyName: String, file: String, note: Int) {
    name = prettyName
    fileName = file
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

  static let shared = Conductor()

  let drumSamples: [DrumSample] =
    [
      DrumSample("OPEN HI HAT", file: "Samples/Drums/open_hi_hat_A#1.wav", note: 34),
      DrumSample("HI TOM", file: "Samples/Drums/hi_tom_D2.wav", note: 38),
      DrumSample("MID TOM", file: "Samples/Drums/mid_tom_B1.wav", note: 35),
      DrumSample("LO TOM", file: "Samples/Drums/lo_tom_F1.wav", note: 29),
      DrumSample("HI HAT", file: "Samples/Drums/closed_hi_hat_F#1.wav", note: 30),
      DrumSample("CLAP", file: "Samples/Drums/clap_D#1.wav", note: 27),
      DrumSample("SNARE", file: "Samples/Drums/snare_D1.wav", note: 26),
      DrumSample("KICK", file: "Samples/Drums/bass_drum_C1.wav", note: 24),
  ]

  let drums = AKAppleSampler()

  func playPad(padNumber: Int) {
    try? drums.play(noteNumber: MIDINoteNumber(drumSamples[padNumber].midiNote))
    let fileName = drumSamples[padNumber].fileName
    lastPlayed = fileName.components(separatedBy: "/").last!
  }

  func start() {
    AKManager.output = drums
    do {
      try AKManager.start()
    } catch let error {
      AKLog("AudioKit did not start! \(error)")
    }
    do {
      let files = drumSamples.map {
        $0.audioFile!
      }
      try drums.loadAudioFiles(files)

    } catch {
      AKLog("Files Didn't Load")
    }
  }

}

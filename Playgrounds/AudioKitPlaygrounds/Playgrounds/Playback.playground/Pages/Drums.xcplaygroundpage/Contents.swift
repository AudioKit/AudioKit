//: ## Drums

import AudioKitPlaygrounds
import AudioKit

let drums = AKSampler()

AudioKit.output = drums
AudioKit.start()

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

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Drums")

        addSubview(AKButton(title: "Bass Drum") { _ in
            drums.play(noteNumber: 36 - 12)
        })
        addSubview(AKButton(title: "Snare Drum") { _ in
            drums.play(noteNumber: 38 - 12)
        })
        addSubview(AKButton(title: "Closed Hi Hat") { _ in
            drums.play(noteNumber: 42 - 12)
        })
        addSubview(AKButton(title: "Open Hi Hat") { _ in
            drums.play(noteNumber: 46 - 12)
        })
        addSubview(AKButton(title: "Lo Tom") { _ in
            drums.play(noteNumber: 41 - 12)
        })
        addSubview(AKButton(title: "Mid Tom") { _ in
            drums.play(noteNumber: 47 - 12)
        })
        addSubview(AKButton(title: "Hi Tom") { _ in
            drums.play(noteNumber: 50 - 12)
        })

        addSubview(AKButton(title: "Clap") { _ in
            drums.play(noteNumber: 39 - 12)
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

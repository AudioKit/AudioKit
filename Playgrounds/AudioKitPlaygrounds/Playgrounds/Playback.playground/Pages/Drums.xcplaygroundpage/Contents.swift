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

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Drums")

        addView(AKButton(title: "Bass Drum") { _ in
            drums.play(noteNumber: 36 - 12)
        })
        addView(AKButton(title: "Snare Drum") { _ in
            drums.play(noteNumber: 38 - 12)
        })
        addView(AKButton(title: "Closed Hi Hat") { _ in
            drums.play(noteNumber: 42 - 12)
        })
        addView(AKButton(title: "Open Hi Hat") { _ in
            drums.play(noteNumber: 46 - 12)
        })
        addView(AKButton(title: "Lo Tom") { _ in
            drums.play(noteNumber: 41 - 12)
        })
        addView(AKButton(title: "Mid Tom") { _ in
            drums.play(noteNumber: 47 - 12)
        })
        addView(AKButton(title: "Hi Tom") { _ in
            drums.play(noteNumber: 50 - 12)
        })

        addView(AKButton(title: "Clap") { _ in
            drums.play(noteNumber: 39 - 12)
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

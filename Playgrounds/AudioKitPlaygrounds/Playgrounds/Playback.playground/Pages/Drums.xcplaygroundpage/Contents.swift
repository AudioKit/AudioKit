//: ## Drums

import AudioKitPlaygrounds
import AudioKit

let drums = AKAppleSampler()

AudioKit.output = drums
try AudioKit.start()

let bassDrumFile = try AKAudioFile(readFileName: "Samples/Drums/bass_drum_C1.wav")
let clapFile = try AKAudioFile(readFileName: "Samples/Drums/clap_D#1.wav")
let closedHiHatFile = try AKAudioFile(readFileName: "Samples/Drums/closed_hi_hat_F#1.wav")
let hiTomFile = try AKAudioFile(readFileName: "Samples/Drums/hi_tom_D2.wav")
let loTomFile = try AKAudioFile(readFileName: "Samples/Drums/lo_tom_F1.wav")
let midTomFile = try AKAudioFile(readFileName: "Samples/Drums/mid_tom_B1.wav")
let openHiHatFile = try AKAudioFile(readFileName: "Samples/Drums/open_hi_hat_A#1.wav")
let snareDrumFile = try AKAudioFile(readFileName: "Samples/Drums/snare_D1.wav")

try drums.audioFiles = [bassDrumFile,
                        clapFile,
                        closedHiHatFile,
                        hiTomFile,
                        loTomFile,
                        midTomFile,
                        openHiHatFile,
                        snareDrumFile]

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Drums")

        addView(AKButton(title: "Bass Drum") { _ in
            self.play(noteNumber: 36)
        })
        addView(AKButton(title: "Snare Drum") { _ in
            self.play(noteNumber: 38)
        })
        addView(AKButton(title: "Closed Hi Hat") { _ in
            self.play(noteNumber: 42)
        })
        addView(AKButton(title: "Open Hi Hat") { _ in
            self.play(noteNumber: 46)
        })
        addView(AKButton(title: "Lo Tom") { _ in
            self.play(noteNumber: 41)
        })
        addView(AKButton(title: "Mid Tom") { _ in
            self.play(noteNumber: 47)
        })
        addView(AKButton(title: "Hi Tom") { _ in
            self.play(noteNumber: 50)
        })
        addView(AKButton(title: "Clap") { _ in
            self.play(noteNumber: 39)
        })
    }

    func play(noteNumber: MIDINoteNumber) {
        do {
            try drums.play(noteNumber: noteNumber - 12)
        } catch {
            AKLog("Could Not Play")
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

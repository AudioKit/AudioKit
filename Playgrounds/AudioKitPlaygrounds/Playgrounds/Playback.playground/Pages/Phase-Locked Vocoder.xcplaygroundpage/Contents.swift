//: ## Phase-Locked Vocoder
//: A different kind of time and pitch stretching
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: "guitarloop.wav")
let phaseLockedVocoder = AKPhaseLockedVocoder(file: file)

AudioKit.output = phaseLockedVocoder
AudioKit.start()
phaseLockedVocoder.start()
phaseLockedVocoder.amplitude = 1
phaseLockedVocoder.pitchRatio = 1

var timeStep = 0.1

import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    // UI Elements we'll need to be able to access
    var playingPositionSlider: AKSlider?

    override func setup() {

        addTitle("Phase Locked Vocoder")

        playingPositionSlider = AKSlider(property: "Position",
                                         value: phaseLockedVocoder.position,
                                         range: 0 ... 3.428,
                                         format: "%0.2f s"
        ) { sliderValue in
            phaseLockedVocoder.position = sliderValue
        }
        addSubview(playingPositionSlider)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

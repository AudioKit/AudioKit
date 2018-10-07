//: ## Tremolo
//: ###
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var tremolo = AKTremolo(player, waveform: AKTable(.positiveSine))
tremolo.depth = 0.5
tremolo.frequency = 8

AudioKit.output = tremolo
try AudioKit.start()

player.play()

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Tremolo")
        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Frequency",
                         value: tremolo.frequency,
                         range: 0 ... 20,
                         format: "%0.3f Hz"
        ) { sliderValue in
            tremolo.frequency = sliderValue
        })

        addView(AKSlider(property: "Depth", value: tremolo.depth) { sliderValue in
            tremolo.depth = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

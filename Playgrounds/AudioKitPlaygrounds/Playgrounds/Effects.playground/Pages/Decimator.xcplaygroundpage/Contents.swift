//: ## Decimator
//: Decimation is a type of digital distortion like bit crushing,
//: but instead of directly stating what bit depth and sample rate you want,
//: it is done through setting "decimation" and "rounding" parameters.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

//: Next, we'll connect the audio sources to a decimator
var decimator = AKDecimator(player)
decimator.decimation = 0.5 // Normalized Value 0 - 1
decimator.rounding = 0.5 // Normalized Value 0 - 1
decimator.mix = 0.5 // Normalized Value 0 - 1

engine.output = decimator
try engine.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Decimator")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Decimation", value: decimator.decimation) { sliderValue in
            decimator.decimation = sliderValue
        })

        addView(AKSlider(property: "Rounding", value: decimator.rounding) { sliderValue in
            decimator.rounding = sliderValue
        })

        addView(AKSlider(property: "Mix", value: decimator.mix) { sliderValue in
            decimator.mix = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

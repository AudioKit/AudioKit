//: ## String Resonator
//: ##
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = AKPlayer(audioFile: file)
player.isLooping = true

var stringResonator = AKStringResonator(player)
stringResonator.feedback = 0.9
stringResonator.fundamentalFrequency = 1_000
stringResonator.rampDuration = 0.1

AudioKit.output = stringResonator
try AudioKit.start()

player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("String Resonator")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Fundamental Frequency",
                         value: stringResonator.fundamentalFrequency,
                         range: 0 ... 5_000,
                         format: "%0.1f Hz"
        ) { sliderValue in
            stringResonator.fundamentalFrequency = sliderValue
        })

        addView(AKSlider(property: "Feedback", value: stringResonator.feedback) { sliderValue in
            stringResonator.feedback = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

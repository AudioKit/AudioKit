//: ## Tone and Tone Complement Filters
//: ##
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var toneFilter = AKToneFilter(player)
var toneComplement = AKToneComplementFilter(toneFilter)

engine.output = toneComplement
try engine.start()

player.play()

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Tone Filters")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop Tone Filter") { button in
            toneFilter.isStarted ? toneFilter.stop() : toneFilter.play()
            button.title = toneFilter.isStarted ? "Stop Tone Filter" : "Start Tone Filter"
        })

        addView(AKSlider(property: "Half Power Point",
                         value: toneFilter.halfPowerPoint,
                         range: 0 ... 10_000,
                         taper: 5
        ) { sliderValue in
            toneFilter.halfPowerPoint = sliderValue
        })

        addView(AKButton(title: "Stop Tone Complement") { button in
            toneComplement.isStarted ? toneComplement.stop() : toneComplement.play()
            button.title = toneComplement.isStarted ? "Stop Tone Complement" : "Start Tone Complement"
        })

        addView(AKSlider(property: "Half Power Point",
                         value: toneComplement.halfPowerPoint,
                         range: 0 ... 10_000,
                         taper: 5
        ) { sliderValue in
            toneComplement.halfPowerPoint = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

//: ## Modal Resonance Filter
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = AKPlayer(audioFile: file)
player.isLooping = true

var filter = AKModalResonanceFilter(player)
filter.frequency = 300 // Hz
filter.qualityFactor = 20

let balancedOutput = AKBalancer(filter, comparator: player)
AudioKit.output = balancedOutput
try AudioKit.start()

player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Modal Resonance Filter")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Frequency",
                         value: filter.frequency,
                         range: 0 ... 5_000,
                         taper: 3,
                         format: "%0.1f Hz"
        ) { sliderValue in
            filter.frequency = sliderValue
        })

        addView(AKSlider(property: "Quality Factor",
                         value: filter.qualityFactor,
                         range: 0.1 ... 20,
                         format: "%0.1f"
        ) { sliderValue in
            filter.qualityFactor = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

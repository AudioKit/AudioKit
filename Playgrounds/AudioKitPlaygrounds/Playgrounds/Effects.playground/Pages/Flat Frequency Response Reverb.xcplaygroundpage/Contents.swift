//: ## Flat Frequency Response Reverb
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var reverb = AKFlatFrequencyResponseReverb(player, loopDuration: 0.1)
reverb.reverbDuration = 1

engine.output = reverb
try engine.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Flat Frequency Response Reverb")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Duration", value: reverb.reverbDuration, range: 0 ... 5) { sliderValue in
            reverb.reverbDuration = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

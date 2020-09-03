//: ## Moog Ladder Filter
//: One of the coolest filters available in AudioKit is the Moog Ladder.
//: It's based off of Robert Moog's iconic ladder filter, which was the
//: first implementation of a voltage - controlled filter used in an
//: analog synthesizer. As such, it was the first filter that gave the
//: ability to use voltage control to determine the cutoff frequency of the
//: filter. As we're dealing with a software implementation, and not an
//: analog synthesizer, we don't have to worry about dealing with
//: voltage control directly. However, by using this node, you can
//: emulate some of the sounds of classic analog synthesizers in your app.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var moogLadder = AKMoogLadder(player)
moogLadder.cutoffFrequency = 300 // Hz
moogLadder.resonance = 0.6

engine.output = moogLadder
try engine.start()

player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Moog Ladder Filter")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Cutoff Frequency",
                         value: moogLadder.cutoffFrequency,
                         range: 40 ... 5_000,
                         taper: 4,
                         format: "%0.1f Hz"
        ) { sliderValue in
            moogLadder.cutoffFrequency = sliderValue
        })

        addView(AKSlider(property: "Resonance",
                         value: moogLadder.resonance,
                         range: 0 ... 0.98
        ) { sliderValue in
            moogLadder.resonance = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

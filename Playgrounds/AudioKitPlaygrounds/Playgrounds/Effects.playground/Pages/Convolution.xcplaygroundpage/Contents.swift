//: ## Convolution
//: Allows you to create a large variety of effects, usually reverbs or environments,
//: but it could also be for modeling.
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let bundle = Bundle.main

var dryWetMixer: AKDryWetMixer!
var mixer: AKDryWetMixer!
var dishConvolution: AKConvolution!
var stairwellConvolution: AKConvolution!

if let stairwell = bundle.url(forResource: "Impulse Responses/stairwell", withExtension: "wav"),
    let dish = bundle.url(forResource: "Impulse Responses/dish", withExtension: "wav") {

    stairwellConvolution = AKConvolution(player,
                                         impulseResponseFileURL: stairwell,
                                         partitionLength: 8_192)
    dishConvolution = AKConvolution(player,
                                    impulseResponseFileURL: dish,
                                    partitionLength: 8_192)
}
mixer = AKDryWetMixer(stairwellConvolution, dishConvolution, balance: 0.5)
dryWetMixer = AKDryWetMixer(player, mixer, balance: 0.5)

engine.output = dryWetMixer
try engine.start()

stairwellConvolution.start()
dishConvolution.start()

player.play()

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Convolution")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Dry Audio to Convolved", value: dryWetMixer.balance) { sliderValue in
            dryWetMixer.balance = sliderValue
        })

        addView(AKSlider(property: "Stairwell to Dish", value: mixer.balance) { sliderValue in
            mixer.balance = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

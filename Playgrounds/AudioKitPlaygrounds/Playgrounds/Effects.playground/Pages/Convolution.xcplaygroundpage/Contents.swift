//: ## Convolution
//: Allows you to create a large variety of effects, usually reverbs or environments,
//: but it could also be for modeling.

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let bundle = Bundle.main

var dryWetMixer: DryWetMixer!
var mixer: DryWetMixer!
var dishConvolution: Convolution!
var stairwellConvolution: Convolution!

if let stairwell = bundle.url(forResource: "Impulse Responses/stairwell", withExtension: "wav"),
    let dish = bundle.url(forResource: "Impulse Responses/dish", withExtension: "wav") {

    stairwellConvolution = Convolution(player,
                                         impulseResponseFileURL: stairwell,
                                         partitionLength: 8_192)
    dishConvolution = Convolution(player,
                                    impulseResponseFileURL: dish,
                                    partitionLength: 8_192)
}
mixer = DryWetMixer(stairwellConvolution, dishConvolution, balance: 0.5)
dryWetMixer = DryWetMixer(player, mixer, balance: 0.5)

engine.output = dryWetMixer
try engine.start()

stairwellConvolution.start()
dishConvolution.start()

player.play()

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Convolution")

        addView(Slider(property: "Dry Audio to Convolved", value: dryWetMixer.balance) { sliderValue in
            dryWetMixer.balance = sliderValue
        })

        addView(Slider(property: "Stairwell to Dish", value: mixer.balance) { sliderValue in
            mixer.balance = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

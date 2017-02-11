//: ## Convolution
//: Allows you to create a large variety of effects, usually reverbs or environments,
//: but it could also be for modeling.
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let bundle = Bundle.main

let stairwell = bundle.url(forResource: "Impulse Responses/stairwell", withExtension: "wav")!
let dish = bundle.url(forResource: "Impulse Responses/dish", withExtension: "wav")!

var stairwellConvolution = AKConvolution(player,
                                         impulseResponseFileURL: stairwell,
                                         partitionLength: 8_192)
var dishConvolution = AKConvolution(player,
                                    impulseResponseFileURL: dish,
                                    partitionLength: 8_192)

var mixer = AKDryWetMixer(stairwellConvolution, dishConvolution, balance: 0.5)
var dryWetMixer = AKDryWetMixer(player, mixer, balance: 0.5)

AudioKit.output = dryWetMixer
AudioKit.start()

stairwellConvolution.start()
dishConvolution.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Convolution")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Dry Audio to Convolved",
            value: dryWetMixer.balance,
            color: AKColor.green
        ) { sliderValue in
            dryWetMixer.balance = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Stairwell to Dish",
            value: mixer.balance,
            color: AKColor.cyan
        ) { sliderValue in
            mixer.balance = sliderValue
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

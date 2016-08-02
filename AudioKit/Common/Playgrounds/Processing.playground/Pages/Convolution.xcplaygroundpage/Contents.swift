//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Convolution
//: ### Allows you to create a large variety of effects, usually reverbs or environments,
//: ### but it could also be for modeling.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let bundle = NSBundle.mainBundle()

let stairwell = bundle.URLForResource("Impulse Responses/stairwell", withExtension: "wav")!
let dish = bundle.URLForResource("Impulse Responses/dish", withExtension: "wav")!

var stairwellConvolution = AKConvolution.init(player,
                                              impulseResponseFileURL: stairwell,
                                              partitionLength: 8192)
var dishConvolution = AKConvolution.init(player,
                                         impulseResponseFileURL: dish,
                                         partitionLength: 8192)

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
            color: AKColor.greenColor()
        ) { sliderValue in
            dryWetMixer.balance = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Stairwell to Dish",
            value: mixer.balance,
            color: AKColor.cyanColor()
        ) { sliderValue in
            mixer.balance = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

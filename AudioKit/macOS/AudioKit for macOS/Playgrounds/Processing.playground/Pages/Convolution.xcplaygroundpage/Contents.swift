//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Convolution
//: ### Allows you to create a large variety of effects, usually reverbs or environments,
//: ### but it could also be for modeling.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
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

        addButtons()

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

    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }
    override func stop() {
        player.stop()
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height:400))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

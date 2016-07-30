//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dynamics Processor
//: ### The AKDynamicsProcessoris both a compressor and an expander based on
//: ### Apple's Dynamics Processor audio unit. threshold and headRoom (similar to
//: ### 'ratio' you might be more familiar with) are specific to the compressor,
//: ### expansionRatio and expansionThreshold control the expander.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var effect = AKDynamicsProcessor(player)

//: Set the parameters here
effect.threshold
effect.headRoom
effect.expansionRatio
effect.expansionThreshold
effect.attackTime
effect.releaseTime
effect.masterGain

AudioKit.output = effect
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Dynamics Processor")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: AKPlaygroundView.audioResourceFileNames))
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        addSubview(AKPropertySlider(
            property: "Threshold",
            format: "%0.2f dB",
            value: effect.threshold, minimum: -40, maximum: 20,
            color: AKColor.greenColor()
        ) { sliderValue in
            effect.threshold = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Head Room",
            format: "%0.2f dB",
            value: effect.headRoom, minimum: 0.1, maximum: 40,
            color: AKColor.greenColor()
        ) { sliderValue in
            effect.headRoom = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Expansion Ratio",
            value: effect.expansionRatio, minimum: 1, maximum: 50,
            color: AKColor.greenColor()
        ) { sliderValue in
            effect.expansionRatio = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Expansion Threshold",
            value: effect.expansionThreshold, minimum: 1, maximum: 50,
            color: AKColor.greenColor()
        ) { sliderValue in
            effect.expansionThreshold = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Attack Time",
            format: "%0.3f s",
            value: effect.attackTime, minimum: 0.0001, maximum: 0.2,
            color: AKColor.greenColor()
        ) { sliderValue in
            effect.attackTime = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Release Time",
            format: "%0.3f s",
            value: effect.releaseTime, minimum: 0.01, maximum: 3,
            color: AKColor.greenColor()
        ) { sliderValue in
            effect.releaseTime = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Master Gain",
            format: "%0.2f dB",
            value: effect.masterGain, minimum: -40, maximum: 40,
            color: AKColor.greenColor()
        ) { sliderValue in
            effect.masterGain = sliderValue
            })
    }


    func process() {
        effect.start()
    }

    func bypass() {
        effect.bypass()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

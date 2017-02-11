//: ## Dynamics Processor
//: The AKDynamicsProcessoris both a compressor and an expander based on
//: Apple's Dynamics Processor audio unit. threshold and headRoom (similar to
//: 'ratio' you might be more familiar with) are specific to the compressor,
//: expansionRatio and expansionThreshold control the expander.
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var effect = AKDynamicsProcessor(player)
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
            filenames: processingPlaygroundFiles))

        addSubview(AKBypassButton(node: effect))

        addSubview(AKPropertySlider(
            property: "Threshold",
            format: "%0.2f dB",
            value: effect.threshold, minimum: -40, maximum: 20,
            color: AKColor.green
        ) { sliderValue in
            effect.threshold = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Head Room",
            format: "%0.2f dB",
            value: effect.headRoom, minimum: 0.1, maximum: 40,
            color: AKColor.green
        ) { sliderValue in
            effect.headRoom = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Expansion Ratio",
            value: effect.expansionRatio, minimum: 1, maximum: 50,
            color: AKColor.green
        ) { sliderValue in
            effect.expansionRatio = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Expansion Threshold",
            value: effect.expansionThreshold, minimum: 1, maximum: 50,
            color: AKColor.green
        ) { sliderValue in
            effect.expansionThreshold = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Attack Time",
            format: "%0.3f s",
            value: effect.attackTime, minimum: 0.000_1, maximum: 0.2,
            color: AKColor.green
        ) { sliderValue in
            effect.attackTime = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Release Time",
            format: "%0.3f s",
            value: effect.releaseTime, minimum: 0.01, maximum: 3,
            color: AKColor.green
        ) { sliderValue in
            effect.releaseTime = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Master Gain",
            format: "%0.2f dB",
            value: effect.masterGain, minimum: -40, maximum: 40,
            color: AKColor.green
        ) { sliderValue in
            effect.masterGain = sliderValue
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

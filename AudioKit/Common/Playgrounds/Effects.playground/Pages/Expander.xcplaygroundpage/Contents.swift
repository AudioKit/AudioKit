//: ## Expander
//: ##
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var expander = AKExpander(player)

AudioKit.output = expander
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Expander")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKBypassButton(node: expander))
        addSubview(AKPropertySlider(
            property: "Ratio",
            format: "%0.2f",
            value: expander.expansionRatio, minimum: 1, maximum: 50
        ) { sliderValue in
            expander.expansionRatio = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Threshold",
            format: "%0.2f",
            value: expander.expansionThreshold, minimum: 1, maximum: 50
        ) { sliderValue in
            expander.expansionThreshold = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Attack Time",
            format: "%0.4f s",
            value: expander.attackTime, minimum: 0.001, maximum: 0.2
        ) { sliderValue in
            expander.attackTime = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Release Time",
            format: "%0.3f s",
            value: expander.releaseTime, minimum: 0.01, maximum: 3
        ) { sliderValue in
            expander.releaseTime = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Master Gain",
            format: "%0.2f dB",
            value: expander.masterGain, minimum: -40, maximum: 40
        ) { sliderValue in
            expander.masterGain = sliderValue
            })

    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

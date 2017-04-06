//: ## Bit Crush Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { input, parameters in
    let baseSampleRate = parameters[0]
    let sampleRateVariation = parameters[1]
    let baseBitDepth = parameters[2]
    let bitDepthVariation = parameters[3]
    let frequency = parameters[4]

    let sinusoid = AKOperation.sineWave(frequency: frequency)
    let sampleRate = baseSampleRate + sinusoid * sampleRateVariation
    let bitDepth = baseBitDepth + sinusoid * bitDepthVariation

    return input.bitCrush(bitDepth: bitDepth, sampleRate: sampleRate)
}
effect.parameters = [22_050, 0, 16, 0, 1]

AudioKit.output = effect
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Bit Crush Operation")
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Base Sample Rate",
            format: "%0.1f Hz",
            value: effect.parameters[0], minimum: 300, maximum: 22_050
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Sample Rate Variation",
            format: "%0.1f Hz",
            value: effect.parameters[1], minimum: 0, maximum: 8_000
        ) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Base Bit Depth",
            format: "%0.3f",
            value: effect.parameters[2], minimum: 1, maximum: 24
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Bit Depth Variation",
            format: "%0.3f",
            value: effect.parameters[3], minimum: 0, maximum: 12
        ) { sliderValue in
            effect.parameters[3] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.3f Hz",
            value: effect.parameters[4], minimum: 0, maximum: 5
        ) { sliderValue in
            effect.parameters[4] = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

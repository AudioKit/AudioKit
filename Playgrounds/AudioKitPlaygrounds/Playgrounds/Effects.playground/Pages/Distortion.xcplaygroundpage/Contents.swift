//: ## Distortion
//: This thing is a beast.
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0], baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var distortion = AKDistortion(player)
distortion.delay = 0.1
distortion.decay = 1.0
distortion.delayMix = 0.5
distortion.linearTerm = 0.5
distortion.squaredTerm = 0.5
distortion.cubicTerm = 50
distortion.polynomialMix = 0.5
distortion.softClipGain = -6
distortion.finalMix = 0.5

AudioKit.output = AKBooster(distortion, gain: 0.1)
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var delaySlider: AKPropertySlider?
    var decaySlider: AKPropertySlider?
    var delayMixSlider: AKPropertySlider?
    var linearTermSlider: AKPropertySlider?
    var squaredTermSlider: AKPropertySlider?
    var cubicTermSlider: AKPropertySlider?
    var polynomialMixSlider: AKPropertySlider?
    var softClipGainSlider: AKPropertySlider?
    var finalMixSlider: AKPropertySlider?

    override func setup() {
        addTitle("Distortion")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: distortion))

        delaySlider = AKPropertySlider(property: "Delay",
                                       value: distortion.delay,
                                       range: 0.1 ... 500,
                                       format: "%0.3f ms",
        ) { sliderValue in
            distortion.delay = sliderValue
        }
        addSubview(delaySlider)

        decaySlider = AKPropertySlider(property: "Decay Rate",
                                       value: distortion.decay,
                                       range: 0.1 ... 50
        ) { sliderValue in
            distortion.decay = sliderValue
        }
        addSubview(decaySlider)

        addSubview(AKPropertySlider(property: "Delay Mix", value: distortion.delayMix) { sliderValue in
            distortion.delayMix = sliderValue
        })

        addSubview(AKPropertySlider(property: "Linear Term", value: distortion.linearTerm) { sliderValue in
            distortion.linearTerm = sliderValue
        })

        addSubview(AKPropertySlider(property: "Squared Term", value: distortion.squaredTerm) { sliderValue in
            distortion.squaredTerm = sliderValue
        })

        addSubview(AKPropertySlider(property: "Cubic Term", value: distortion.cubicTerm) { sliderValue in
            distortion.cubicTerm = sliderValue
        })

        addSubview(AKPropertySlider(property: "Polynomial Mix", value: distortion.polynomialMix) { sliderValue in
            distortion.polynomialMix = sliderValue
        })

        softClipGainSlider = AKPropertySlider(property: "Soft Clip Gain",
                                              value: distortion.softClipGain,
                                              range: -80 ... 20,
                                              format: "%0.3f dB"
        ) { sliderValue in
            distortion.softClipGain = sliderValue
        }
        addSubview(softClipGainSlider)

        addSubview(AKPropertySlider(property: "Final Mix", value: distortion.finalMix) { sliderValue in
            distortion.finalMix = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

//: ## String Resonator
//: ##
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0], baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var stringResonator = AKStringResonator(player)
stringResonator.feedback = 0.9
stringResonator.fundamentalFrequency = 1_000
stringResonator.rampTime = 0.1

AudioKit.output = stringResonator
AudioKit.start()

player.play()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("String Resonator")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKPropertySlider(property: "Fundamental Frequency",
                                    value: stringResonator.fundamentalFrequency,
                                    range: 0 ... 5_000,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            stringResonator.fundamentalFrequency = sliderValue
        })

        addSubview(AKPropertySlider(property: "Feedback", value: stringResonator.feedback) { sliderValue in
            stringResonator.feedback = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

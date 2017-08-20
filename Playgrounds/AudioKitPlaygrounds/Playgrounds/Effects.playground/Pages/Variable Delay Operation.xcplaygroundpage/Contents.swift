//: ## Variable Delay Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, parameters in
    let time = AKOperation.sineWave(frequency: parameters[1])
        .scale(minimum: 0.001, maximum: parameters[0])
    let feedback = AKOperation.sineWave(frequency: parameters[2])
        .scale(minimum: 0.5, maximum: 0.9)
    return player.variableDelay(time: time,
                                feedback: feedback,
                                maximumDelayTime: 1.0)
}
effect.parameters = [0.2, 0.3, 0.21]

AudioKit.output = effect
AudioKit.start()
player.play()

//: User Interface

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Variable Delay Operation")
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: playgroundAudioFiles))

        addSubview(AKPropertySlider(
            property: "Maximum Delay",
            format: "%0.3f s",
            value: effect.parameters[0], maximum: 0.3) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Delay Frequency",
            format: "%0.3f Hz",
            value: effect.parameters[1]) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Feedback Frequency",
            format: "%0.3f Hz",
            value: effect.parameters[2]) { sliderValue in
            effect.parameters[2] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

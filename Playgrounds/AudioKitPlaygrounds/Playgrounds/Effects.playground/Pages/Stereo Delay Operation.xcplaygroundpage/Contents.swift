//: ## Stereo Delay Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player, numberOfChannels: 2) { _, parameters in
    let leftDelay = AKOperation.leftInput.variableDelay(time: parameters[0], feedback: parameters[1])
    let rightDelay = AKOperation.rightInput.variableDelay(time: parameters[2], feedback: parameters[3])
    return [leftDelay, rightDelay]
}
effect.parameters = [0.2, 0.5, 0.01, 0.9]

AudioKit.output = effect
AudioKit.start()
player.play()

//: User Interface

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Stereo Delay Operation")
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Left Delay",
            format: "%0.3f s",
            value: effect.parameters[0], maximum: 0.3) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Left Feedback",
            format: "%0.3f",
            value: effect.parameters[1]) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Right Delay",
            format: "%0.3f s",
            value: effect.parameters[2], maximum: 0.3) { sliderValue in
            effect.parameters[2] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Left Feedback",
            format: "%0.3f",
            value: effect.parameters[3]) { sliderValue in
            effect.parameters[3] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

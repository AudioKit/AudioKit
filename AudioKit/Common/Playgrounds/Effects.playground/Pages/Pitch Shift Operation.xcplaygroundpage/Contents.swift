//: ## Pitch Shift Operation
//:

import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, parameters in
    let sinusoid = AKOperation.sineWave(frequency: parameters[2])
    let shift = parameters[0] + sinusoid * parameters[1] / 2.0
    return player.pitchShift(semitones: shift)
}
effect.parameters = [0, 7, 3]

AudioKit.output = effect
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Pitch Shift Operation")
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Base Shift",
            format: "%0.3f semitones",
            value: effect.parameters[0], minimum: -12, maximum: 12
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Range",
            format: "%0.3f semitones",
            value: effect.parameters[1], minimum: 0, maximum: 24
        ) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Speed",
            format: "%0.3f Hz",
            value: effect.parameters[2], minimum: 0.001, maximum: 10
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

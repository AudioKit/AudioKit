//: ## AutoPan Operation
//:
import PlaygroundSupport
import AudioKit

//: This first section sets up parameter naming in such a way
//: to make the operation code easier to read below.

let speedIndex = 0
let depthIndex = 1

extension AKOperationEffect {
    var speed: Double {
        get { return self.parameters[speedIndex] }
        set(newValue) { self.parameters[speedIndex] = newValue }
    }
    var depth: Double {
        get { return self.parameters[depthIndex] }
        set(newValue) { self.parameters[depthIndex] = newValue }
    }
}

//: Use the struct and the extension to refer to the autopan parameters by name

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { input, parameters in
    let oscillator = AKOperation.sineWave(frequency: parameters[speedIndex],
                                          amplitude: parameters[depthIndex])
    return input.pan(oscillator)
}

effect.parameters = [10, 1]
AudioKit.output = effect
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("AutoPan")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Speed",
            value: effect.speed, minimum: 0.1, maximum: 25,
            color: AKColor.green
        ) { sliderValue in
            effect.speed = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Depth",
            value: effect.depth,
            color: AKColor.red
        ) { sliderValue in
            effect.depth = sliderValue
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

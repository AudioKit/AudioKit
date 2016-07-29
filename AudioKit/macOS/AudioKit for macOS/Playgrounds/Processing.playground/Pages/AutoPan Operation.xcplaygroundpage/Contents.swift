//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AutoPan Operation
//:
import XCPlayground
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

//: Here we'll use the struct and the extension to refer to the autopan parameters by name

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

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

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("AutoPan")

        addButtons()

        addSubview(AKPropertySlider(
            property: "Speed",
            value: effect.speed, minimum: 0.1, maximum: 25,
            color: AKColor.greenColor()
        ) { sliderValue in
            effect.speed = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Depth",
            value: effect.depth,
            color: AKColor.redColor()
        ) { sliderValue in
            effect.depth = sliderValue
            })
    }

    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }

    override func stop() {
        player.stop()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

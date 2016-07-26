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
    var speedLabel: Label?
    var depthLabel: Label?

    override func setup() {
        addTitle("AutoPan")

        addButtons()

        speedLabel = addLabel("Speed: \(effect.speed)")
        addSlider(#selector(setSpeed), value: effect.speed, minimum: 0.1, maximum: 25)

        depthLabel = addLabel("Depth: \(effect.depth)")
        addSlider(#selector(setDepth), value: effect.depth)
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

    func setSpeed(slider: Slider) {
        effect.speed = Double(slider.value)
        speedLabel!.text = "Speed: \(String(format: "%0.3f", effect.speed))"
        printParameters()
    }

    func setDepth(slider: Slider) {
        effect.depth = Double(slider.value)
        depthLabel!.text = "Depth: \(String(format: "%0.3f", effect.depth))"
        printParameters()
    }

    func printParameters() {
        let realSpeed = effect.parameters[speedIndex]
        let realDepth = effect.parameters[depthIndex]
        Swift.print("speed = \(realSpeed), depth = \(realDepth)")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

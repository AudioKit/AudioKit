//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AutoPan Operation
//:
import XCPlayground
import AudioKit

//: This first section sets up parameter naming in such a way to make the operation code easier to read below.

enum AutoPanParameter: Int {
    case Speed, Depth
}

struct AutoPan {
    static var speed: AKOperation {
        return AKOperation.parameters(AutoPanParameter.Speed.rawValue)
    }
    static var depth: AKOperation {
        return AKOperation.parameters(AutoPanParameter.Depth.rawValue)
    }
}

extension AKOperationEffect {
    var speed: Double {
        get { return self.parameters[AutoPanParameter.Speed.rawValue] }
        set(newValue) { self.parameters[AutoPanParameter.Speed.rawValue] = newValue }
    }
    var depth: Double {
        get { return self.parameters[AutoPanParameter.Depth.rawValue] }
        set(newValue) { self.parameters[AutoPanParameter.Depth.rawValue] = newValue }
    }
}

//: Here we'll use the struct and the extension to refer to the autopan parameters by name

let file = try AKAudioFile(forReadingWithFileName: "guitarloop.wav", fromBaseDirectory: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let oscillator = AKOperation.sineWave(frequency: AutoPan.speed, amplitude: AutoPan.depth)

let panner = AKOperation.input.pan(oscillator)

let effect = AKOperationEffect(player, stereoOperation: panner)
effect.parameters = [10, 1]
AudioKit.output = effect
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView {
    var speedLabel: Label?
    var depthLabel: Label?

    override func setup() {
        addTitle("AutoPan")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        speedLabel = addLabel("Speed: \(effect.speed)")
        addSlider(#selector(setSpeed), value: effect.speed, minimum: 0.1, maximum: 25)

        depthLabel = addLabel("Depth: \(effect.depth)")
        addSlider(#selector(setDepth), value: effect.depth)
    }


    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(forReadingWithFileName: "\(part)loop.wav", fromBaseDirectory: .resources)
        try player.replaceFile(file!)
        player.play()
    }

    func startDrumLoop() {
        startLoop("drum")
    }

    func startBassLoop() {
        startLoop("bass")
    }

    func startGuitarLoop() {
        startLoop("guitar")
    }

    func startLeadLoop() {
        startLoop("lead")
    }

    func startMixLoop() {
        startLoop("mix")
    }
    func stop() {
        player.stop()
    }

    func setSpeed(slider: Slider) {
        effect.speed = Double(slider.value)
        speedLabel!.text = "Speed: \(String(format: "%0.3f", effect.speed))"
    }

    func setDepth(slider: Slider) {
        effect.depth = Double(slider.value)
        depthLabel!.text = "Depth: \(String(format: "%0.3f", effect.depth))"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next]

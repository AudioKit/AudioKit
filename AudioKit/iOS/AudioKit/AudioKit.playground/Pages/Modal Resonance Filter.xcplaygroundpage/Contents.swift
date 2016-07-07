//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Modal Resonance Filter
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var filter = AKModalResonanceFilter(player)

filter.frequency = 300 // Hz
filter.qualityFactor = 20

let balancedOutput = AKBalancer(filter, comparator: player)
AudioKit.output = balancedOutput
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var frequencyLabel: Label?
    var qualityFactorLabel: Label?

    override func setup() {
        addTitle("Modal Resonance Filter")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        frequencyLabel = addLabel("Frequency: \(filter.frequency)")
        addSlider(#selector(setFrequency), value: filter.frequency, minimum: 0, maximum: 5000)

        qualityFactorLabel = addLabel("Quality Factor: \(filter.qualityFactor)")
        addSlider(#selector(setQualityFactor), value: filter.qualityFactor, minimum: 0, maximum: 20)
    }

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(part)loop.wav", baseDir: .Resources)
        try? player.replaceFile(file!)
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

    func setFrequency(slider: Slider) {
        filter.frequency = Double(slider.value)
        frequencyLabel!.text = "Frequency: \(String(format: "%0.0f", filter.frequency))"
        printCode()
    }

    func setQualityFactor(slider: Slider) {
        filter.qualityFactor = Double(slider.value)
        qualityFactorLabel!.text = "Quality Factor: \(String(format: "%0.1f", filter.qualityFactor))"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        print("public func presetXXXXXX() {")
        print("    frequency = \(String(format: "%0.3f", filter.frequency))")
        print("    qualityFactor = \(String(format: "%0.3f", filter.qualityFactor))")
        print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

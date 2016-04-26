//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Metronome
//:
import AudioKit
import XCPlayground

var currentFrequency = 60.0
let beep = AKOperation.sineWave(frequency: 480)

let trig = AKOperation.metronome(AKOperation.parameters(0) / 60)

let beeps = beep.triggeredWithEnvelope(
    trig,
    attack: 0.01, hold: 0, release: 0.05)

let generator = AKOperationGenerator(operation: beeps)
generator.parameters = [currentFrequency]

AudioKit.output = generator
AudioKit.start()
generator.start()

class PlaygroundView: AKPlaygroundView {

    var frequencyLabel: Label?

    override func setup() {
        addTitle("Metronome")

        frequencyLabel = addLabel("Frequency: \(currentFrequency) BPM")
        addSlider(#selector(setFrequency), value: currentFrequency, minimum: 20, maximum: 320)
    }

    func setFrequency(slider: Slider) {
        currentFrequency = Double(slider.value)
        generator.parameters = [currentFrequency]
        frequencyLabel!.text = "Frequency: \(String(format: "%0.1f", currentFrequency)) BPM"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

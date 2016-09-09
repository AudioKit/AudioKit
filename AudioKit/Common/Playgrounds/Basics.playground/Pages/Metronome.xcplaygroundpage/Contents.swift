//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Metronome
//:
//: Although AudioKit operations are a somewhat advanced topic, this
//: is a simple example of creating a metronome with operations.
//: It's just important that you know that operations that can do very
//: complex synthesis and effect processing is capable in AudioKit.
import AudioKit
import XCPlayground

var currentFrequency = 60.0

let generator = AKOperationGenerator() { parameters in
    let beep = AKOperation.sineWave(frequency: 480)

    let metronome = AKOperation.metronome(frequency: parameters[0] / 60)

    let beeps = beep.triggeredWithEnvelope(
        trigger: metronome,
        attack: 0.01, hold: 0, release: 0.05)
    return beeps
}

generator.parameters = [currentFrequency]

AudioKit.output = generator
AudioKit.start()
generator.start()


class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Metronome")

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.2f BPM",
            value: 60, minimum: 40, maximum: 240,
            color: AKColor.greenColor()
        ) { frequency in
            generator.parameters[0] = frequency
        })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

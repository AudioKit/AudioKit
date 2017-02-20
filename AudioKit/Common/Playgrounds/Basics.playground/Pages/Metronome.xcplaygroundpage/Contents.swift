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
import PlaygroundSupport

var currentFrequency = 60.0

let generator = AKOperationGenerator { parameters in

    let metronome = AKOperation.metronome(frequency: parameters[0] / 60)

    let count = metronome.count(maximum: parameters[1], looping: true)

    let beep = AKOperation.sineWave(frequency: 480 * (2 - (count / parameters[1] + 0.49).round()))

    let beeps = beep.triggeredWithEnvelope(
        trigger: metronome,
        attack: 0.01, hold: 0, release: 0.05)
    return beeps
}

generator.parameters = [currentFrequency, 4]

AudioKit.output = generator
AudioKit.start()
generator.start()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Metronome")
        
        addSubview(AKButton(title: "Stop") {
            generator.stop()
            return ""
        })
        
        addSubview(AKButton(title: "Start") {
            generator.restart()
            return ""
        })
        
        addSubview(AKPropertySlider(
            property: "Sudivision",
            format: "%0.0f",
            value: 4, minimum: 1, maximum: 10,
            color: AKColor.red
        ) { sudivision in
            generator.parameters[1] = round(sudivision)
        })


        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.2f BPM",
            value: 60, minimum: 40, maximum: 240,
            color: AKColor.green
        ) { frequency in
            generator.parameters[0] = frequency
        })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

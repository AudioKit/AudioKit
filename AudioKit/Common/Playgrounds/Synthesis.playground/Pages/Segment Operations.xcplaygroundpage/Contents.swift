//: ## Segment Operations
//: Creating segments that vary parameters in operations linearly or exponentially over a certain duration
import PlaygroundSupport
import AudioKit

let generator = AKOperationGenerator() { parameters in
    let updateRate = parameters[0]

    // Vary the starting frequency and duration randomly
    let start = AKOperation.randomNumberPulse() * 2000 + 300
    let duration = AKOperation.randomNumberPulse()
    let frequency = AKOperation.lineSegment(
        trigger: AKOperation.metronome(frequency: updateRate),
        start: start,
        end: 0,
        duration: duration)

    // Decrease the amplitude exponentially
    let amplitude = AKOperation.exponentialSegment(
        trigger: AKOperation.metronome(frequency: updateRate),
        start: 0.3,
        end: 0.01,
        duration: 1.0 / updateRate)
    return AKOperation.sineWave(frequency: frequency, amplitude:  amplitude)
}


var delay = AKDelay(generator)

//: Add some effects for good fun
delay.time = 0.125
delay.feedback = 0.8
var reverb = AKReverb(delay)
reverb.loadFactoryPreset(.largeHall)

AudioKit.output = reverb
AudioKit.start()

generator.parameters = [2.0]
generator.start()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Segment Operations")

        addSubview(AKPropertySlider(
            property: "Update Rate",
            format: "%0.3f Hz",
            value: generator.parameters[0], minimum: 0.1, maximum: 10,
            color: AKColor.red
        ) { rate in
            generator.parameters[0] = rate
            delay.time = 0.25 / rate
            })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

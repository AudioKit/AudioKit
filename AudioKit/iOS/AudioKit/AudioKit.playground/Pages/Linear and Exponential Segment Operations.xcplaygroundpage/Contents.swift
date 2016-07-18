//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Linear and Exponential Segment Operations
//: ### You can create segments that vary parameters in operations over a certain duration.  Here we create an alien apocalypse.
//:
import XCPlayground
import AudioKit

let updateRate = AKOperation.parameters(0)

//: Vary the starting frequency and duration randomly
let start = AKOperation.randomNumberPulse() * 2000 + 300
let duration = AKOperation.randomNumberPulse()
let frequency = AKOperation.lineSegment(AKOperation.metronome(updateRate),
                                        start: start,
                                        end: 0,
                                        duration: duration)

//: Decrease the amplitude exponentially
let amplitude = AKOperation.exponentialSegment(AKOperation.metronome(updateRate),
                                               start: 0.3,
                                               end: 0.01,
                                               duration: 1.0 / updateRate)
let sine = AKOperation.sineWave(frequency: frequency, amplitude:  amplitude)

let generator = AKOperationGenerator(operation:  sine)

var delay = AKDelay(generator)

//: Add some effects for good fun
delay.time = 0.125
delay.feedback = 0.8
var reverb = AKReverb(delay)
reverb.loadFactoryPreset(.LargeHall)

AudioKit.output = reverb
AudioKit.start()

generator.parameters = [2.0]
generator.start()

class PlaygroundView: AKPlaygroundView {
    var speedLabel: Label?

    override func setup() {
        addTitle("Segment Operations")

        speedLabel = addLabel("Update Rate: \(generator.parameters[0])")
        addSlider(#selector(setSpeed), value: generator.parameters[0], minimum: 0.1, maximum: 10)

    }

    func setSpeed(slider: Slider) {
        generator.parameters[0] = Double(slider.value)
        speedLabel!.text = "Update Rate: \(String(format: "%0.3f", generator.parameters[0]))"
        delay.time = 0.25 / Double(slider.value)
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

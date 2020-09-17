//: ## Segment Operations
//: Creating segments that vary parameters in operations linearly or exponentially over a certain duration

import AudioKit

let generator = OperationGenerator { parameters in
    let updateRate = parameters[0]

    // Vary the starting frequency and duration randomly
    let start = Operation.randomNumberPulse() * 2_000 + 300
    let duration = Operation.randomNumberPulse()
    let frequency = Operation.lineSegment(trigger: Operation.metronome(frequency: updateRate),
                                            start: start,
                                            end: 0,
                                            duration: duration)

    // Decrease the amplitude exponentially
    let amplitude = Operation.exponentialSegment(trigger: Operation.metronome(frequency: updateRate),
                                                   start: 0.3,
                                                   end: 0.01,
                                                   duration: 1.0 / updateRate)
    return Operation.sineWave(frequency: frequency, amplitude: amplitude)
}

var delay = Delay(generator)

//: Add some effects for good fun
delay.time = 0.125
delay.feedback = 0.8
var reverb = Reverb(delay)
reverb.loadFactoryPreset(.largeHall)

engine.output = reverb
try engine.start()

generator.parameters = [2.0]
generator.start()

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Segment Operations")

        addView(Slider(property: "Update Rate",
                         value: generator.parameters[0],
                         range: 0.1 ... 10,
                         format: "%0.3f Hz"
        ) { sliderValue in
            generator.parameters[0] = sliderValue
            delay.time = 0.25 / sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

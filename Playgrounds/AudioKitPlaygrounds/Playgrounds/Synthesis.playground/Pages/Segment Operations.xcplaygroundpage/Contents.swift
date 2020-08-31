//: ## Segment Operations
//: Creating segments that vary parameters in operations linearly or exponentially over a certain duration
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let generator = AKOperationGenerator { parameters in
    let updateRate = parameters[0]

    // Vary the starting frequency and duration randomly
    let start = AKOperation.randomNumberPulse() * 2_000 + 300
    let duration = AKOperation.randomNumberPulse()
    let frequency = AKOperation.lineSegment(trigger: AKOperation.metronome(frequency: updateRate),
                                            start: start,
                                            end: 0,
                                            duration: duration)

    // Decrease the amplitude exponentially
    let amplitude = AKOperation.exponentialSegment(trigger: AKOperation.metronome(frequency: updateRate),
                                                   start: 0.3,
                                                   end: 0.01,
                                                   duration: 1.0 / updateRate)
    return AKOperation.sineWave(frequency: frequency, amplitude: amplitude)
}

var delay = AKDelay(generator)

//: Add some effects for good fun
delay.time = 0.125
delay.feedback = 0.8
var reverb = AKReverb(delay)
reverb.loadFactoryPreset(.largeHall)

engine.output = reverb
try engine.start()

generator.parameters = [2.0]
generator.start()

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Segment Operations")

        addView(AKSlider(property: "Update Rate",
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

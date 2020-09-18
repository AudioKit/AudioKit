//: ## Tracking Frequency
//: Tracking frequency is just as easy as tracking amplitude, and even
//: includes amplitude, but it is more CPU intensive, so if you just need amplitude,
//: use the amplitude tracker.

import AudioKit

//: First lets set up sound source to track
let oscillatorNode = OperationGenerator {
    // Let's set up the volume to be changing in the shape of a sine wave
    let volume = Operation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 0.5)

    // And let's make the frequency also be a sineWave
    let frequency = Operation.sineWave(frequency: 0.1).scale(minimum: 100, maximum: 2_200)

    return Operation.sineWave(frequency: frequency, amplitude: volume)
}

let tracker = PitchTap(oscillatorNode)
let fader = Fader(tracker, gain: 0.5)
let secondaryOscillator = Oscillator()

//: The frequency tracker passes its input to the output,
//: so we can insert into the signal chain at the bottom
engine.output = Mixer(fader, secondaryOscillator)
try engine.start()

oscillatorNode.start()
secondaryOscillator.start()

//: User Interface

class LiveView: View {

    var trackedAmplitudeSlider: Slider!
    var trackedFrequencySlider: Slider!

    override func viewDidLoad() {

        PlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
            secondaryOscillator.frequency = tracker.frequency
            secondaryOscillator.amplitude = tracker.amplitude
        }

        addTitle("Tracking Frequency")

        trackedAmplitudeSlider = Slider(property: "Tracked Amplitude", range: 0 ... 0.8) { _ in
            // Do nothing, just for display
        }
        addView(trackedAmplitudeSlider)

        trackedFrequencySlider = Slider(property: "Tracked Frequency",
                                          range: 0 ... 2_400,
                                          format: "%0.3f Hz"
        ) { _ in
            // Do nothing, just for display
        }
        addView(trackedFrequencySlider)

        addView(RollingOutputPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

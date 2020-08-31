//: ## Tracking Frequency
//: Tracking frequency is just as easy as tracking amplitude, and even
//: includes amplitude, but it is more CPU intensive, so if you just need amplitude,
//: use the amplitude tracker.
import AudioKitPlaygrounds
import AudioKit

//: First lets set up sound source to track
let oscillatorNode = AKOperationGenerator {
    // Let's set up the volume to be changing in the shape of a sine wave
    let volume = AKOperation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 0.5)

    // And let's make the frequency also be a sineWave
    let frequency = AKOperation.sineWave(frequency: 0.1).scale(minimum: 100, maximum: 2_200)

    return AKOperation.sineWave(frequency: frequency, amplitude: volume)
}

let tracker = AKPitchTap(oscillatorNode)
let booster = AKBooster(tracker, gain: 0.5)
let secondaryOscillator = AKOscillator()

//: The frequency tracker passes its input to the output,
//: so we can insert into the signal chain at the bottom
engine.output = AKMixer(booster, secondaryOscillator)
try engine.start()

oscillatorNode.start()
secondaryOscillator.start()

//: User Interface
import AudioKitUI

class LiveView: AKLiveViewController {

    var trackedAmplitudeSlider: AKSlider!
    var trackedFrequencySlider: AKSlider!

    override func viewDidLoad() {

        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
            secondaryOscillator.frequency = tracker.frequency
            secondaryOscillator.amplitude = tracker.amplitude
        }

        addTitle("Tracking Frequency")

        trackedAmplitudeSlider = AKSlider(property: "Tracked Amplitude", range: 0 ... 0.8) { _ in
            // Do nothing, just for display
        }
        addView(trackedAmplitudeSlider)

        trackedFrequencySlider = AKSlider(property: "Tracked Frequency",
                                          range: 0 ... 2_400,
                                          format: "%0.3f Hz"
        ) { _ in
            // Do nothing, just for display
        }
        addView(trackedFrequencySlider)

        addView(AKRollingOutputPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

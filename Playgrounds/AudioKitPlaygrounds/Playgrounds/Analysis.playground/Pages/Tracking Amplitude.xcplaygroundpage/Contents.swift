//: ## Tracking Amplitude
//: Determing the amplitude of an audio signal by
//: outputting the value of a generator node into the AKAmplitudeTap.
//: This node is great if you want to build an app that does audio monitoring and analysis.
import AudioKitPlaygrounds
import AudioKit

//: First lets set up sound source to track
let oscillatorNode = AKOperationGenerator {
    // Let's set up the volume to be changing in the shape of a sine wave
    let volume = AKOperation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 0.5)

    // And lets make the frequency move around to make sure it doesn't affect the amplitude tracking
    let frequency = AKOperation.jitter(amplitude: 200, minimumFrequency: 10, maximumFrequency: 30) + 200

    // So our oscillator will move around randomly in frequency and have a smoothly varying amplitude
    return AKOperation.sineWave(frequency: frequency, amplitude: volume)
}

let trackedAmplitude = AKAmplitudeTap(oscillatorNode)
engine.output = trackedAmplitude
try engine.start()
oscillatorNode.start()
trackedAmplitude.start()

//: User Interface
import AudioKitUI

class LiveView: AKLiveViewController {

    var trackedAmplitudeSlider: AKSlider!

    override func viewDidLoad() {

        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = trackedAmplitude.amplitude
        }

        addTitle("Tracking Amplitude")

        trackedAmplitudeSlider = AKSlider(property: "Tracked Amplitude", range: 0 ... 0.55) { _ in
            // Do nothing, just for display
        }
        addView(trackedAmplitudeSlider)

        addView(AKRollingOutputPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.liveView = LiveView()

//: This keeps the playground running so that audio can play for a long time
PlaygroundPage.current.needsIndefiniteExecution = true

//: Experiment with this playground by changing the volume function to a
//: phasor or another well-known function to see how well the amplitude tracker
//: can track.  Also, you could change the sound source from an oscillator to a
//: noise generator, or any constant sound source (some things like a physical
//: model would not work because the output has an envelope to its volume).
//: Instead of just plotting our results, we could use the value to drive other
//: sounds or update an app's user interface.

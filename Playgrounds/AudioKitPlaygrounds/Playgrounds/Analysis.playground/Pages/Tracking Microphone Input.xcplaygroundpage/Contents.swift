//: ## Tracking Microphone Input
//:
import AudioKitPlaygrounds
import AudioKit

// In this trivial example, we of course initialise the microphone node before we assign AudioKit.output
// - there is no other way to structure this. However, in a real world application there may be cases
// where you could do it the other way around. If you create your microphone node after you assign to
// AudioKit.output, your microphone node may only return zeros as samples. So, as a rule of thumb:
// Always create your microphone node first.
let mic = AKMicrophone()

// Create two copies of the microphone node (each one will be tapped once to supply data for plots

let micCopy1 = AKBooster(mic)
let micCopy2 = AKBooster(mic)
let micCopy3 = AKBooster(mic)

//: Set the microphone device if you need to
//if let inputs = AudioKit.inputDevices {
//    try AudioKit.setInputDevice(inputs[0])
//    try mic.setDevice(inputs[0])
//}
let tracker = AKFrequencyTracker(micCopy2, hopSize: 4_096, peakCount: 20)
let silence = AKBooster(tracker, gain: 0)

//: The frequency tracker passes its input to the output,
//: so we can insert into the signal chain at the bottom
AudioKit.output = silence
try AudioKit.start()

//: User Interface
import AudioKitUI

class LiveView: AKLiveViewController {

    var trackedAmplitudeSlider: AKSlider!
    var trackedFrequencySlider: AKSlider!

    override func viewDidLoad() {

        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
        }

        addTitle("Tracking Microphone Input")

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

        let fftPlot = AKNodeFFTPlot(micCopy1, frame: CGRect(x: 0, y: 0, width: 500, height: 200))
        fftPlot.shouldFill = true
        fftPlot.shouldMirror = false
        fftPlot.shouldCenterYAxis = false
        fftPlot.color = AKColor.purple
        fftPlot.gain = 100
        addView(fftPlot)

        let rollingPlot = AKNodeOutputPlot(micCopy2, frame: CGRect(x: 0, y: 0, width: 440, height: 200))
        rollingPlot.plotType = .rolling
        rollingPlot.shouldFill = true
        rollingPlot.shouldMirror = true
        rollingPlot.color = AKColor.red
        rollingPlot.gain = 2
        addView(rollingPlot)

        let plot = AKNodeOutputPlot(micCopy3, frame: CGRect(x: 0, y: 0, width: 440, height: 200))
        plot.plotType = .buffer
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = AKColor.blue
        plot.gain = 2
        addView(plot)

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

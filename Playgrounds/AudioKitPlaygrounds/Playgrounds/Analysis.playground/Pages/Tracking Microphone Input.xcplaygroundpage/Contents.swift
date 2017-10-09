//: ## Tracking Microphone Input
//:
import AudioKitPlaygrounds
import AudioKit

let mic = AKMicrophone()

// Create two copies of the microphone node (each one will be tapped once to supply data for plots

let micCopy1 = AKBooster(mic)
let micCopy2 = AKBooster(mic)

//: Set the microphone device if you need to
if let inputs = AudioKit.inputDevices {
    try AudioKit.setInputDevice(inputs[0])
    try mic.setDevice(inputs[0])
}
let tracker = AKFrequencyTracker(micCopy2, hopSize: 200, peakCount: 2_000)
let silence = AKBooster(tracker, gain: 0)

//: The frequency tracker passes its input to the output,
//: so we can insert into the signal chain at the bottom
AudioKit.output = silence
AudioKit.start()

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

        let fftPlot = AKNodeFFTPlot(mic, frame: CGRect(x: 0, y: 0, width: 500, height: 200))
        fftPlot.shouldFill = true
        fftPlot.shouldMirror = false
        fftPlot.shouldCenterYAxis = false
        fftPlot.color = AKColor.purple
        fftPlot.gain = 100
        addView(fftPlot)

        let rollingPlot = AKNodeOutputPlot(micCopy1, frame: CGRect(x: 0, y: 0, width: 440, height: 200))
        rollingPlot.plotType = .buffer
        rollingPlot.shouldFill = true
        rollingPlot.shouldMirror = true
        rollingPlot.color = AKColor.red
        rollingPlot.gain = 2
        addView(rollingPlot)

        let plot = AKNodeOutputPlot(micCopy2, frame: CGRect(x: 0, y: 0, width: 440, height: 200))
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = AKColor.blue
        plot.gain = 2
        plot.shouldOptimizeForRealtimePlot = false
        addView(plot)

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

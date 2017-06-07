//: ## Tracking Microphone Input
//:
import AudioKitPlaygrounds
import AudioKit

let mic = AKMicrophone()

// Create two copies of the microphone node (each one will be tapped once to supply data for plots

let micCopy1 = AKBooster(mic)
let micCopy2 = AKBooster(micCopy1)

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

class PlaygroundView: AKPlaygroundView {

    var trackedAmplitudeSlider: AKPropertySlider?
    var trackedFrequencySlider: AKPropertySlider?

    override func setup() {

        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
        }

        addTitle("Tracking Microphone Input")

        trackedAmplitudeSlider = AKPropertySlider(
            property: "Tracked Amplitude",
            format: "%0.3f",
            value: 0, maximum: 0.8,
            color: AKColor.green
        ) { _ in
            // Do nothing, just for display
        }
        addSubview(trackedAmplitudeSlider)

        trackedFrequencySlider = AKPropertySlider(
            property: "Tracked Frequency",
            format: "%0.3f",
            value: 0, maximum: 2_400,
            color: AKColor.red
        ) { _ in
            // Do nothing, just for display
        }
        addSubview(trackedFrequencySlider)

        let fftPlot = AKNodeFFTPlot(mic, frame: CGRect(x: 0, y: 0, width: 500, height: 200))
        fftPlot.shouldFill = true
        fftPlot.shouldMirror = false
        fftPlot.shouldCenterYAxis = false
        fftPlot.color = AKColor.purple
        fftPlot.gain = 100
        addSubview(fftPlot)

        let rollingPlot = AKNodeOutputPlot(micCopy1, frame: CGRect(x: 0, y: 0, width: 440, height: 200))
        rollingPlot.plotType = .buffer
        rollingPlot.shouldFill = true
        rollingPlot.shouldMirror = true
        rollingPlot.color = AKColor.red
        rollingPlot.gain = 2
        addSubview(rollingPlot)

        let plot = AKNodeOutputPlot(micCopy2, frame: CGRect(x: 0, y: 0, width: 440, height: 200))
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = AKColor.blue
        plot.gain = 2
        plot.shouldOptimizeForRealtimePlot = false
        addSubview(plot)

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

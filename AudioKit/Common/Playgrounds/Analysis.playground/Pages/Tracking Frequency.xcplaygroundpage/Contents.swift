//: ## Tracking Frequency
//: ### Tracking frequency is just as easy as tracking amplitude, and even
//: ### includes amplitude, but it is more CPU intensive, so if you just need amplitude,
//: ### use the amplitude tracker.
import XCPlayground
import AudioKit

//: First lets set up sound source to track
let oscillatorNode = AKOperationGenerator() { _ in
    // Let's set up the volume to be changing in the shape of a sine wave
    let volume = AKOperation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 0.5)

    // And let's make the frequency also be a sineWave
    let frequency = AKOperation.sineWave(frequency: 0.1).scale(minimum: 100, maximum: 2200)

    return AKOperation.sineWave(frequency: frequency, amplitude: volume)
}

let tracker = AKFrequencyTracker(oscillatorNode)
let booster = AKBooster(tracker, gain: 1)
let secondaryOscillator = AKOscillator()

//: The frequency tracker passes its input to the output,
//: so we can insert into the signal chain at the bottom
AudioKit.output = AKMixer(booster, secondaryOscillator)
AudioKit.start()

oscillatorNode.start()
secondaryOscillator.start()

//: User Interface

class PlaygroundView: AKPlaygroundView {
    
    var trackedAmplitudeSlider: AKPropertySlider?
    var trackedFrequencySlider: AKPropertySlider?
    
    override func setup() {
        
        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
            secondaryOscillator.frequency = tracker.frequency
            secondaryOscillator.amplitude = tracker.amplitude
        }
        
        addTitle("Tracking Frequency")
        
        trackedAmplitudeSlider = AKPropertySlider(
            property: "Tracked Amplitude",
            format: "%0.3f",
            value: 0, maximum: 0.8,
            color: AKColor.greenColor()
        ) { sliderValue in
            // Do nothing, just for display
        }
        addSubview(trackedAmplitudeSlider!)

        trackedFrequencySlider = AKPropertySlider(
            property: "Tracked Frequency",
            format: "%0.3f",
            value: 0, maximum: 2400,
            color: AKColor.redColor()
        ) { sliderValue in
            // Do nothing, just for display
        }
        addSubview(trackedFrequencySlider!)

        addSubview(AKRollingOutputPlot.createView())
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

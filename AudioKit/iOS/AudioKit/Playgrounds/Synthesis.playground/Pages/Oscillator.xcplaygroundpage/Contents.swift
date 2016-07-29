//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive FM Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKOscillator()
oscillator.amplitude = 0.1
AudioKit.output = oscillator
AudioKit.start()
oscillator.play()

class PlaygroundView: AKPlaygroundView {

    var frequencyLabel: Label?
    var amplitudeLabel: Label?

    override func setup() {
        addTitle("Oscillator")

        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.2f Hz",
            value: oscillator.frequency, minimum: 220, maximum: 880,
            color: AKColor.yellowColor()
        ) { frequency in
            oscillator.frequency = frequency
        })
        
        addSubview(AKPropertySlider(
            property: "Amplitude",
            format: "%0.3f",
            value: oscillator.amplitude,
            color: AKColor.magentaColor()
        ) { amplitude in
            oscillator.amplitude = amplitude
        })
    }

    func start() {
        oscillator.play()
    }

    func stop() {
        oscillator.stop()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 330))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

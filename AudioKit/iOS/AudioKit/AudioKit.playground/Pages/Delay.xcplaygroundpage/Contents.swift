//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var delay = AKDelay(player)

//: Set the parameters of the delay here
delay.time = 0.01 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

AudioKit.output = delay
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var timeLabel: Label?
    var feedbackLabel: Label?
    var lowPassCutoffFrequencyLabel: Label?
    var dryWetMixLabel: Label?

    override func setup() {
        addTitle("Delay")

        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        timeLabel = addLabel("Time: \(delay.time)")
        addSlider(#selector(self.setTime(_:)), value: delay.time, minimum: 0, maximum: 1)

        feedbackLabel = addLabel("Feedback: \(delay.feedback)")
        addSlider(#selector(self.setFeedback(_:)), value: delay.feedback)

        lowPassCutoffFrequencyLabel = addLabel("Low Pass Cutoff Frequency: \(delay.lowPassCutoff)")
        addSlider(#selector(self.setLowPassCutoffFrequency(_:)), value: delay.lowPassCutoff, minimum: 0, maximum: 22050)

        dryWetMixLabel = addLabel("Mix: \(delay.dryWetMix)")
        addSlider(#selector(self.setDryWetMix(_:)), value: delay.dryWetMix)
    }

    //: Handle UI Events

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func setTime(slider: Slider) {
        delay.time = Double(slider.value)
        let time = String(format: "%0.3f", delay.time)
        timeLabel!.text = "Time: \(time)"
    }

    func setFeedback(slider: Slider) {
        delay.feedback = Double(slider.value)
        let feedback = String(format: "%0.2f", delay.feedback)
        feedbackLabel!.text = "Feedback: \(feedback)"
    }

    func setLowPassCutoffFrequency(slider: Slider) {
        delay.lowPassCutoff = Double(slider.value)
        let lowPassCutoff = String(format: "%0.2f Hz", delay.lowPassCutoff)
        lowPassCutoffFrequencyLabel!.text = "Low Pass Cutoff Frequency: \(lowPassCutoff)"
    }

    func setDryWetMix(slider: Slider) {
        delay.dryWetMix = Double(slider.value)
        let dryWetMix = String(format: "%0.2f", delay.dryWetMix)
        dryWetMixLabel!.text = "Mix: \(dryWetMix)"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

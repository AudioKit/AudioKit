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

        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        timeLabel = addLabel("Time: \(delay.time)")
        addSlider(#selector(setTime), value: delay.time, minimum: 0, maximum: 1)

        feedbackLabel = addLabel("Feedback: \(delay.feedback)")
        addSlider(#selector(setFeedback), value: delay.feedback)

        lowPassCutoffFrequencyLabel = addLabel("Low Pass Cutoff Frequency: \(delay.lowPassCutoff)")
        addSlider(#selector(setLowPassCutoffFrequency), value: delay.lowPassCutoff, minimum: 0, maximum: 22050)

        dryWetMixLabel = addLabel("Mix: \(delay.dryWetMix)")
        addSlider(#selector(setDryWetMix), value: delay.dryWetMix)
    }

    //: Handle UI Events

    func startLoop(part: String) {
        player.stop()
        let file = bundle.pathForResource("\(part)loop", ofType: "wav")
        player.replaceFile(file!)
        player.play()
    }
    
    func startDrumLoop() {
        startLoop("drum")
    }
    
    func startBassLoop() {
        startLoop("bass")
    }
    
    func startGuitarLoop() {
        startLoop("guitar")
    }
    
    func startLeadLoop() {
        startLoop("lead")
    }
    
    func startMixLoop() {
        startLoop("mix")
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

    f
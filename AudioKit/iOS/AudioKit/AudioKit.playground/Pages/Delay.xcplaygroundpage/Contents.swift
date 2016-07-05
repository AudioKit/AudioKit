//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Delay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
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
    
    var timeSlider: Slider?
    var feedbackSlider: Slider?
    var lowPassCutoffFrequencySlider: Slider?
    var dryWetMixSlider: Slider?

    override func setup() {
        addTitle("Delay")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        timeLabel = addLabel("Time: \(delay.time)")
        dryWetMixSlider = addSlider(#selector(setTime), value: delay.time, minimum: 0, maximum: 1)

        feedbackLabel = addLabel("Feedback: \(delay.feedback)")
        feedbackSlider = addSlider(#selector(setFeedback), value: delay.feedback)

        lowPassCutoffFrequencyLabel = addLabel("Low Pass Cutoff Frequency: \(delay.lowPassCutoff)")
        lowPassCutoffFrequencySlider = addSlider(#selector(setLowPassCutoffFrequency), value: delay.lowPassCutoff, minimum: 0, maximum: 22050)

        dryWetMixLabel = addLabel("Mix: \(delay.dryWetMix)")
        dryWetMixSlider = addSlider(#selector(setDryWetMix), value: delay.dryWetMix)
        
        addButton("Short Tail Delay", action: #selector(presetShortTailDelay))
        addButton("Dense Long Tail Delay", action: #selector(presetDenseLongTailDelay))
        addButton("Electric Circuits Delay", action: #selector(presetElectricCircuitsDelay))
    }

    //: Handle UI Events

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(part)loop.wav", baseDir: .Resources)
        try? player.replaceFile(file!)
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
        printCode()
    }

    func setFeedback(slider: Slider) {
        delay.feedback = Double(slider.value)
        let feedback = String(format: "%0.2f", delay.feedback)
        feedbackLabel!.text = "Feedback: \(feedback)"
        printCode()
    }

    func setLowPassCutoffFrequency(slider: Slider) {
        delay.lowPassCutoff = Double(slider.value)
        let lowPassCutoff = String(format: "%0.2f Hz", delay.lowPassCutoff)
        lowPassCutoffFrequencyLabel!.text = "Low Pass Cutoff Frequency: \(lowPassCutoff)"
        printCode()
    }

    func setDryWetMix(slider: Slider) {
        delay.dryWetMix = Double(slider.value)
        let dryWetMix = String(format: "%0.2f", delay.dryWetMix)
        dryWetMixLabel!.text = "Mix: \(dryWetMix)"
        printCode()
    }

    func presetShortTailDelay() {
        delay.presetShortTailDelay()
        delay.start()
        updateUI()
    }
    
    func presetDenseLongTailDelay() {
        delay.presetDenseLongTailDelay()
        delay.start()
        updateUI()
    }
    
    func presetElectricCircuitsDelay() {
        delay.presetElectricCircuitsDelay()
        delay.start()
        updateUI()
    }
    
    func updateSliders() {
        timeSlider?.value = Float(delay.time)
        feedbackSlider?.value = Float(delay.feedback)
        lowPassCutoffFrequencySlider?.value = Float(delay.lowPassCutoff)
        dryWetMixSlider?.value = Float(delay.dryWetMix)
    }
    
    func updateTextFields() {
        let delayTime = String(format: "%0.1f", delay.time)
        timeLabel!.text = "\(delayTime)"
        
        let feedback = String(format: "%0.3f", delay.feedback)
        feedbackLabel!.text = "\(feedback)"
        
        let lowPassCutoff = String(format: "%0.3f", delay.lowPassCutoff)
        lowPassCutoffFrequencyLabel!.text = "\(lowPassCutoff)"

        let dryWetMix = String(format: "%0.3f", delay.dryWetMix)
        dryWetMixLabel!.text = "\(dryWetMix)"

    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        print("public func presetXXXXXX() {")
        print("    time = \(String(format: "%0.3f", delay.time))")
        print("    feedback = \(String(format: "%0.3f", delay.feedback))")
        print("    lowPassCutoff = \(String(format: "%0.3f", delay.lowPassCutoff))")
        print("    dryWetMix = \(String(format: "%0.3f", delay.dryWetMix))")
        print("}\n")
    }
    
    func updateUI() {
        updateTextFields()
        updateSliders()
        printCode()
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Moog Ladder Filter
//: ### One of the coolest filters available in AudioKit is the Moog Ladder. It's based off of Robert Moog's iconic ladder filter, which was the first implementation of a voltage - controlled filter used in an analog synthesizer. As such, it was the first filter that gave the ability to use voltage control to determine the cutoff frequency of the filter. As we're dealing with a software implementation, and not an analog synthesizer, we don't have to worry about dealing with voltage control directly. However, by using this node, you can emulate some of the sounds of classic analog synthesizers in your app.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "mixloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var moogLadder = AKMoogLadder(player)

//: Set the parameters of the Moog Ladder Filter here.
moogLadder.cutoffFrequency = 300 // Hz
moogLadder.resonance = 0.6

AudioKit.output = moogLadder
AudioKit.start()

player.play()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    var cutoffFrequencyLabel: Label?
    var resonanceLabel: Label?
    var rampTimeLabel: Label?
    var cutoffFrequencySlider: Slider?
    var resonanceSlider: Slider?
    var rampTimeSlider: Slider?
    
    override func setup() {
        addTitle("Moog Ladder Filter")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        cutoffFrequencyLabel = addLabel("Cutoff Frequency: \(moogLadder.cutoffFrequency)")
        cutoffFrequencySlider = addSlider(#selector(setCutoffFrequency), value: moogLadder.cutoffFrequency, minimum: 0, maximum: 5000)

        resonanceLabel = addLabel("Resonance: \(moogLadder.resonance)")
        resonanceSlider =  addSlider(#selector(setResonance), value: moogLadder.resonance, minimum: 0, maximum: 0.99)
        
        rampTimeLabel = addLabel("Ramp Time: \(moogLadder.rampTime)")
        rampTimeSlider = addSlider(#selector(setRampTime), value: moogLadder.rampTime, minimum: 0, maximum: 2)
        
        addButton("Fog Filter", action: #selector(presetFogMoogLadder))
        addButton("Short Tail Delay", action: #selector(presetDullNoiseMoogLadder))
    }

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

    func setCutoffFrequency(slider: Slider) {
        moogLadder.cutoffFrequency = Double(slider.value)
        cutoffFrequencyLabel!.text = "Cutoff Frequency: \(String(format: "%0.0f", moogLadder.cutoffFrequency))"
        printCode()
    }

    func setResonance(slider: Slider) {
        moogLadder.resonance = Double(slider.value)
        resonanceLabel!.text = "Resonance: \(String(format: "%0.3f", moogLadder.resonance))"
        printCode()
    }
    
    func setRampTime(slider: Slider) {
        moogLadder.rampTime = Double(slider.value)
        let rampTime = String(format: "%0.3f", moogLadder.rampTime)
        rampTimeLabel!.text = "Ramp Time: \(rampTime)"
    }
    
    
    //: Audition Presets
    
    func presetFogMoogLadder() {
        moogLadder.presetFogMoogLadder()
        updateUI()
    }
    
    func presetDullNoiseMoogLadder() {
        moogLadder.presetDullNoiseMoogLadder()
        updateUI()
    }
    
    func updateUI() {
        updateTextFields()
        updateSliders()
        printCode()
    }
    
    func updateSliders() {
        cutoffFrequencySlider?.value = Float(moogLadder.cutoffFrequency)
        resonanceSlider?.value = Float(moogLadder.resonance)
        rampTimeSlider?.value = Float(moogLadder.rampTime)
    }
    
    func updateTextFields() {
        let cutoffFrequency = String(format: "%0.3f", moogLadder.cutoffFrequency)
        cutoffFrequencyLabel!.text = "\(cutoffFrequency)"
        
        let resonance = String(format: "%0.3f", moogLadder.resonance)
        resonanceLabel!.text = "\(resonance)"
        
        let rampTime = String(format: "%0.3f", moogLadder.rampTime)
        rampTimeLabel!.text = "\(rampTime)"
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code
        
        print("public func presetXXXXXX() {")
        print("    cutoffFrequency = \(String(format: "%0.3f", moogLadder.cutoffFrequency))")
        print("    resonance = \(String(format: "%0.3f", moogLadder.resonance))")
        print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 450))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

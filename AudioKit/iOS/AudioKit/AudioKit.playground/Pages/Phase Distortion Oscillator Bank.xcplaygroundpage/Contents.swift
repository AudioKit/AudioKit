//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phase Distorion Oscillator Bank

import XCPlayground
import AudioKit

let osc = AKPhaseDistortionOscillatorBank(waveform: AKTable(.Square))

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, KeyboardDelegate {
    
    var phaseDistortionLabel: Label?
    var attackLabel: Label?
    var releaseLabel: Label?
    var detuningOffsetLabel: Label?
    var detuningMultiplierLabel: Label?
    
    override func setup() {
        addTitle("Phase Distortion Oscillator Bank")
        phaseDistortionLabel = addLabel("Phase Distortion: \(osc.phaseDistortion)")
        addSlider(#selector(setphaseDistortion), value: osc.phaseDistortion, minimum: 0.0, maximum: 0.9999)
        
        attackLabel = addLabel("Attack: \(osc.attackDuration)")
        addSlider(#selector(setAttack), value: osc.attackDuration, minimum: 0.0, maximum: 2.0)
        
        releaseLabel = addLabel("Release: \(osc.releaseDuration)")
        addSlider(#selector(setRelease), value: osc.releaseDuration, minimum: 0.0, maximum: 2.0)
        
        detuningOffsetLabel = addLabel("Detuning Offset: \(osc.detuningOffset)")
        addSlider(#selector(setDetuningOffset), value: osc.detuningOffset, minimum: -1000, maximum: 1000)
        detuningMultiplierLabel = addLabel("Detuning Multiplier: \(osc.detuningMultiplier)")
        addSlider(#selector(setDetuningMultiplier), value: osc.detuningMultiplier, minimum: 0.9, maximum: 1.1)
        
        let keyboard = PolyphonicKeyboardView(width: 500, height: 100)
        keyboard.frame.origin.y = CGFloat(yPosition)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.addSubview(keyboard)
    }
    
    func noteOn(note: Int) {
        osc.play(noteNumber: note, velocity: 80)
    }
    
    func noteOff(note: Int) {
        osc.stop(noteNumber: note)
    }
    
    func setphaseDistortion(slider: Slider) {
        osc.phaseDistortion = Double(slider.value)
        phaseDistortionLabel!.text = "Phase Distortion: \(String(format: "%0.3f", osc.phaseDistortion))"
    }
    
    func setAttack(slider: Slider) {
        osc.attackDuration = Double(slider.value)
        attackLabel!.text = "Attack: \(String(format: "%0.3f", osc.attackDuration))"
    }
    
    func setRelease(slider: Slider) {
        osc.releaseDuration = Double(slider.value)
        releaseLabel!.text = "Release: \(String(format: "%0.3f", osc.releaseDuration))"
    }
    
    func setDetuningOffset(slider: Slider) {
        osc.detuningOffset = Double(slider.value)
        detuningOffsetLabel!.text = "Detuning Offset: \(String(format: "%0.3f", osc.detuningOffset))"
    }
    
    func setDetuningMultiplier(slider: Slider) {
        osc.detuningMultiplier = Double(slider.value)
        detuningMultiplierLabel!.text = "Detuning Multiplier: \(String(format: "%0.3f", osc.detuningMultiplier))"
    }
    
}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

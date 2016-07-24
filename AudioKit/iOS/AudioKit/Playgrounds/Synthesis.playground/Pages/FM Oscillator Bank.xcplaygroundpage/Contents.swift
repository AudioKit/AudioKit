//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator Bank
//: ### Open the timeline view to use the controls this playground sets up.
//:

import XCPlayground
import AudioKit

let fmBank = AKFMOscillatorBank()

AudioKit.output = fmBank
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {
    var carrierMultiplierLabel: Label?
    var modulatingMultiplierLabel: Label?
    var modulationIndexLabel: Label?

    var attackLabel: Label?
    var releaseLabel: Label?

    override func setup() {
        addTitle("FM Oscillator Bank")


        carrierMultiplierLabel = addLabel("Carrier Multiplier: \(fmBank.carrierMultiplier)")
        addSlider(#selector(setCarrierMultiplier),
                  value: fmBank.carrierMultiplier,
                  minimum: 0.0,
                  maximum: 2.0)

        modulatingMultiplierLabel = addLabel("Modulating Multiplier: \(fmBank.modulatingMultiplier)")
        addSlider(#selector(setModulatingMultiplier),
                  value: fmBank.modulatingMultiplier,
                  minimum: 0.0,
                  maximum: 2.0)

        modulationIndexLabel = addLabel("Modulation Index: \(fmBank.modulationIndex)")
        addSlider(#selector(setModulationIndex),
                  value: fmBank.modulationIndex,
                  minimum: 0.0,
                  maximum: 20.0)


        attackLabel = addLabel("Attack: \(fmBank.attackDuration)")
        addSlider(#selector(setAttack), value: fmBank.attackDuration, minimum: 0.0, maximum: 2.0)

        releaseLabel = addLabel("Release: \(fmBank.releaseDuration)")
        addSlider(#selector(setRelease), value: fmBank.releaseDuration, minimum: 0.0, maximum: 2.0)

        let keyboard = AKPolyphonicKeyboardView(width: 500, height: 100)
        keyboard.frame.origin.y = CGFloat(yPosition)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.addSubview(keyboard)
    }

    func noteOn(note: Int) {
        fmBank.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: Int) {
        fmBank.stop(noteNumber: note)
    }

    func setCarrierMultiplier(slider: Slider) {
        fmBank.carrierMultiplier = Double(slider.value)
        carrierMultiplierLabel!.text =
            "Carrier Multiplier: \(String(format: "%0.3f", fmBank.carrierMultiplier))"
    }

    func setModulatingMultiplier(slider: Slider) {
        fmBank.modulatingMultiplier = Double(slider.value)
        modulatingMultiplierLabel!.text =
            "Modulating Multiplier: \(String(format: "%0.3f", fmBank.modulatingMultiplier))"
    }

    func setModulationIndex(slider: Slider) {
        fmBank.modulationIndex = Double(slider.value)
        modulationIndexLabel!.text =
            "Modulation Index: \(String(format: "%0.3f", fmBank.modulationIndex))"
    }

    func setAttack(slider: Slider) {
        fmBank.attackDuration = Double(slider.value)
        attackLabel!.text = "Attack: \(String(format: "%0.3f", fmBank.attackDuration))"
    }

    func setRelease(slider: Slider) {
        fmBank.releaseDuration = Double(slider.value)
        releaseLabel!.text = "Release: \(String(format: "%0.3f", fmBank.releaseDuration))"
    }


}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

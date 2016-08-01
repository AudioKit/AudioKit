//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Morphing Oscillator Bank

import XCPlayground
import AudioKit

let osc = AKMorphingOscillatorBank()

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {
    
    var keyboard: AKKeyboardView?

    override func setup() {
        addTitle("Morphing Oscillator Bank")

        addSubview(AKPropertySlider(
            property: "Morph Index",
            value: osc.index, maximum: 3,
            color: AKColor.redColor()
        ) { index in
            osc.index = index
            })

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f s",
            value: osc.attackDuration, maximum: 2,
            color: AKColor.greenColor()
        ) { duration in
            osc.attackDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f s",
            value: osc.releaseDuration, maximum: 2,
            color: AKColor.greenColor()
        ) { duration in
            osc.releaseDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Detuning Offset",
            format: "%0.1f Cents",
            value:  osc.releaseDuration, minimum: -1200, maximum: 1200,
            color: AKColor.greenColor()
        ) { offset in
            osc.detuningOffset = offset
            })

        addSubview(AKPropertySlider(
            property: "Detuning Multiplier",
            value:  osc.detuningMultiplier, minimum: 0.5, maximum: 2.0,
            color: AKColor.greenColor()
        ) { multiplier in
            osc.detuningMultiplier = multiplier
            })

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        addSubview(keyboard!)
        
        addSubview(AKButton(title: "Toggle Polyphony") {
            self.keyboard?.polyphonicMode = !self.keyboard!.polyphonicMode
            })
    }

    func noteOn(note: MIDINoteNumber) {
        osc.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        osc.stop(noteNumber: note)
    }
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

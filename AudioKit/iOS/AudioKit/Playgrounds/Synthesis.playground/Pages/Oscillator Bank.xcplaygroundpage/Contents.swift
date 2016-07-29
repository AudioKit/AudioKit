//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Oscillator Bank
import XCPlayground
import AudioKit

let osc = AKOscillatorBank(waveform: AKTable(.Sine),
                           attackDuration: 0.1,
                           releaseDuration: 0.1)

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("Oscillator Bank")

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f",
            value: osc.attackDuration, maximum: 2,
            color: AKColor.greenColor()
        ) { duration in
            osc.attackDuration = duration
            })
        
        addSubview(AKPropertySlider(
            property: "Decay",
            format: "%0.3f",
            value: osc.decayDuration, maximum: 2,
            color: AKColor.cyanColor()
        ) { duration in
            osc.decayDuration = duration
            })
        
        addSubview(AKPropertySlider(
            property: "Sustain Level",
            format: "%0.3f",
            value: osc.sustainLevel,
            color: AKColor.yellowColor()
        ) { level in
            osc.sustainLevel = level
            })
        
        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f",
            value:  osc.releaseDuration, maximum: 2,
            color: AKColor.greenColor()
        ) { duration in
            osc.releaseDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Detuning Offset",
            format: "%0.3f",
            value:  osc.releaseDuration, minimum: -1200, maximum: 1200,
            color: AKColor.greenColor()
        ) { offset in
            osc.detuningOffset = offset
            })

        addSubview(AKPropertySlider(
            property: "Detuning Multiplier",
            format: "%0.3f",
            value:  osc.releaseDuration, minimum: 0.5, maximum: 2.0,
            color: AKColor.greenColor()
        ) { multiplier in
            osc.detuningMultiplier = multiplier
            })

        let keyboard = AKPolyphonicKeyboardView(width: 500, height: 100)
        keyboard.delegate = self
        addSubview(keyboard)
    }

    func noteOn(note: MIDINoteNumber) {
        osc.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        osc.stop(noteNumber: note)
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 750))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

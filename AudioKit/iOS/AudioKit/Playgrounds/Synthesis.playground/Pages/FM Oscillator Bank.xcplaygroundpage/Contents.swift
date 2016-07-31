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

    override func setup() {
        addTitle("FM Oscillator Bank")


        addSubview(AKPropertySlider(
            property: "Carrier Multiplier",
            format: "%0.3f",
            value: fmBank.carrierMultiplier, maximum: 2,
            color: AKColor.redColor()
        ) { multiplier in
            fmBank.carrierMultiplier = multiplier
            })
        
        addSubview(AKPropertySlider(
            property: "Modulating Multiplier",
            format: "%0.3f",
            value: fmBank.modulatingMultiplier, maximum: 2,
            color: AKColor.greenColor()
        ) { multiplier in
            fmBank.modulatingMultiplier = multiplier
            })
        
        addSubview(AKPropertySlider(
            property: "Modulation Index",
            format: "%0.3f",
            value: fmBank.modulationIndex, maximum: 20,
            color: AKColor.cyanColor()
        ) { index in
            fmBank.modulationIndex = index
            })

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f",
            value: fmBank.attackDuration, maximum: 2,
            color: AKColor.greenColor()
        ) { duration in
            fmBank.attackDuration = duration
            })
        
        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f",
            value: fmBank.releaseDuration, maximum: 2,
            color: AKColor.greenColor()
        ) { duration in
            fmBank.releaseDuration = duration
            })

        let keyboard = AKPolyphonicKeyboardView(width: Int(self.bounds.width) - 60, height: 100)
        keyboard.delegate = self
        addSubview(keyboard)
    }

    func noteOn(note: MIDINoteNumber) {
        fmBank.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        fmBank.stop(noteNumber: note)
    }

}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

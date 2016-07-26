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


        self.addSubview(AKPropertySlider(
            property: "Carrier Multiplier",
            format: "%0.3f",
            value: fmBank.carrierMultiplier, maximum: 2,
            color: AKColor.redColor(),
            frame: CGRect(x: 30, y: 390, width: self.bounds.width - 60, height: 60)
        ) { multiplier in
            fmBank.carrierMultiplier = multiplier
            })
        
        self.addSubview(AKPropertySlider(
            property: "Modulating Multiplier",
            format: "%0.3f",
            value: fmBank.modulatingMultiplier, maximum: 2,
            color: AKColor.greenColor(),
            frame: CGRect(x: 30, y: 300, width: self.bounds.width - 60, height: 60)
        ) { multiplier in
            fmBank.modulatingMultiplier = multiplier
            })
        
        self.addSubview(AKPropertySlider(
            property: "Modulation Index",
            format: "%0.3f",
            value: fmBank.modulationIndex, maximum: 20,
            color: AKColor.cyanColor(),
            frame: CGRect(x: 30, y: 210, width: self.bounds.width - 60, height: 60)
        ) { index in
            fmBank.modulationIndex = index
            })

        self.addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f",
            value: fmBank.modulatingMultiplier, maximum: 2,
            color: AKColor.greenColor(),
            frame: CGRect(x: 30, y: 120, width: self.bounds.width - 60, height: 60)
        ) { duration in
            fmBank.attackDuration = duration
            })
        
        self.addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f",
            value: fmBank.releaseDuration, maximum: 2,
            color: AKColor.greenColor(),
            frame: CGRect(x: 30, y: 30, width: self.bounds.width - 60, height: 60)
        ) { duration in
            fmBank.releaseDuration = duration
            })

        let keyboard = AKPolyphonicKeyboardView(width: Int(self.bounds.width) - 60, height: 100)
        keyboard.frame.origin.x = 30
        keyboard.frame.origin.y = 480
        keyboard.delegate = self
        self.addSubview(keyboard)
    }

    func noteOn(note: Int) {
        fmBank.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: Int) {
        fmBank.stop(noteNumber: note)
    }

}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

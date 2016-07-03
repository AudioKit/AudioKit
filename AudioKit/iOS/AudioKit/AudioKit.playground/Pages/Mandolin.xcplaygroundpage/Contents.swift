//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mandolin
//: ### Physical model of a mandolin
import AudioKit
import XCPlayground

let playRate = 2.0

let mandolin = AKMandolin()
mandolin.detune = 1
mandolin.bodySize = 1
var pluckPosition = 0.2

var delay  = AKDelay(mandolin)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = AKReverb(delay)

AudioKit.output = reverb
AudioKit.start()
let scale = [0, 2, 4, 5, 7, 9, 11, 12]

class PlaygroundView: AKPlaygroundView {
    
    var detuneLabel: Label?
    var bodySizeLabel: Label?
    var pluckPositionLabel: Label?
    
    override func setup() {
        addTitle("Mandolin")

        detuneLabel = addLabel("Detune: \(mandolin.detune)")
        addSlider(#selector(setDetune), value: mandolin.detune, minimum: 0.5, maximum: 2.0)

        bodySizeLabel = addLabel("Body Size: \(mandolin.bodySize)")
        addSlider(#selector(setBodySize), value: mandolin.bodySize, minimum: 0.2, maximum: 3.0)
        
        pluckPositionLabel = addLabel("Pluck Position: \(pluckPosition)")
        addSlider(#selector(setPluckPosition), value: pluckPosition)
    }

    func setDetune(slider: Slider) {
        mandolin.detune = Double(slider.value)
        let detune = String(format: "%0.2f", mandolin.detune)
        detuneLabel!.text = "Detune: \(detune)"
        printCode()
    }

    func setBodySize(slider: Slider) {
        mandolin.bodySize = Double(slider.value)
        let bodySize = String(format: "%0.2f", mandolin.bodySize)
        bodySizeLabel!.text = "Body Size: \(bodySize)"
        printCode()
    }
    
    func setPluckPosition(slider: Slider) {
        pluckPosition = Double(slider.value)
        let position = String(format: "%0.2f",pluckPosition)
        pluckPositionLabel!.text = "Pluck Position: \(position)"
        printCode()
    }
    
    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code
        
        print("public func presetXXXXXX() {")
        print("    detune = \(String(format: "%0.3f", mandolin.detune))")
        print("    bodySize = \(String(format: "%0.3f", mandolin.bodySize))")
        print("    pluckPosition = \(String(format: "%0.3f", pluckPosition))")
        print("}\n")
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.liveView = view

AKPlaygroundLoop(frequency: playRate) {
    var note1 = scale.randomElement()
    let octave1 = randomInt(2...5)  * 12
    let course1 = randomInt(1...4)
    if random(0, 10) < 1.0 { note1 += 1 }

    var note2 = scale.randomElement()
    let octave2 = randomInt(2...5)  * 12
    let course2 = randomInt(1...4)
    if random(0, 10) < 1.0 { note2 += 1 }


    if random(0, 6) > 1.0 {
        mandolin.fret(noteNumber: note1+octave1, course: course1 - 1)
        mandolin.pluck(course: course1 - 1, position: pluckPosition, velocity: 127)
    }
    if random(0, 6) > 3.0 {
        mandolin.fret(noteNumber: note2+octave2, course: course2 - 1)
        mandolin.pluck(course: course2 - 1, position: pluckPosition, velocity: 127)
    }

}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

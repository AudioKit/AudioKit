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

    var detuneSlider: AKPropertySlider?
    var bodySizeSlider: AKPropertySlider?

    override func setup() {
        addTitle("Mandolin")
        
        detuneSlider = AKPropertySlider(
            property: "Detune",
            format: "%0.2f",
            value: mandolin.detune, minimum: 0.5, maximum: 2,
            color: AKColor.magentaColor(),
            frame: CGRect(x: 30, y: 210, width: self.bounds.width - 60, height: 60)
        ) { detune in
            mandolin.detune = detune
        }
        self.addSubview(detuneSlider!)
        
        bodySizeSlider = AKPropertySlider(
            property: "Body Size",
            format: "%0.2f",
            value: mandolin.bodySize, minimum: 0.2, maximum: 3,
            color: AKColor.cyanColor(),
            frame: CGRect(x: 30, y: 120, width: self.bounds.width - 60, height: 60)
        ) { bodySize in
            mandolin.bodySize = bodySize
        }
        self.addSubview(bodySizeSlider!)


        self.addSubview(AKPropertySlider(
            property: "Pluck Position",
            format: "%0.2f",
            value: pluckPosition,
            color: AKColor.redColor(),
            frame: CGRect(x: 30, y: 30, width: self.bounds.width - 60, height: 60)
        ) { position in
            pluckPosition = position
        })

 
        addButton("Large Resonant Mandolin", action: #selector(presetLargeResonance))
        addButton("Electric Guitar Mandolin", action: #selector(presetElectricGuitar))
        addLineBreak()
        addButton("Small-Bodied Distorted Mandolin",
                  action: #selector(presetSmallDistortedMandolin))
        addButton("Acid Mandolin", action: #selector(presetAcidMandolin))
    }

    //: Audition Presets

    func presetLargeResonance() {
        mandolin.presetLargeResonantMandolin()
        updateUI()
    }

    func presetElectricGuitar() {
        mandolin.presetElectricGuitarMandolin()
        updateUI()
    }

    func presetSmallDistortedMandolin() {
        mandolin.presetSmallBodiedDistortedMandolin()
        updateUI()
    }

    func presetAcidMandolin() {
        mandolin.presetAcidMandolin()
        updateUI()
    }

    func updateUI() {
        detuneSlider!.value = mandolin.detune
        bodySizeSlider!.value = mandolin.bodySize
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    detune = \(String(format: "%0.3f", mandolin.detune))")
        Swift.print("    bodySize = \(String(format: "%0.3f", mandolin.bodySize))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 550, height: 450))
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

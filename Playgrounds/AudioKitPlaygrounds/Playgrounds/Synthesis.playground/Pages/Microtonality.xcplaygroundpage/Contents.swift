//: ## Microtonality

import AudioKitPlaygrounds
import AudioKit

// osc can be FM, Osc, Morph Osc, Phase Distortion Osc, PWM Osc
let osc = AKMorphingOscillatorBank()
AudioKit.output = osc
AudioKit.start()

// Default is 12-tone equal temperament
AKPolyphonicNode.tuningTable.twelveToneEqualTemperament()

let scalaPath = try Bundle.main.path(forResource: "hexany_1_45_135_225", ofType: "scl")

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func setup() {
        addTitle("Microtonal Morphing Oscillator")
        
        // presets view
        let presets = ["12 tone equal temperament", "Highland BagPipes", "Recurrence Relation 01", "Madhubanti", "Hexany 1,45,135,225", "Hexany 1,5,9,15"]
        
        addSubview(AKPresetLoaderView(presets: presets) { preset in
            switch preset {
            case "12 tone equal temperament":
                AKPolyphonicNode.tuningTable.twelveToneEqualTemperament()
            case "Recurrence Relation 01":
                AKPolyphonicNode.tuningTable.presetRecurrenceRelation01()
            case "Madhubanti":
                AKPolyphonicNode.tuningTable.presetPersian17NorthIndian17Madhubanti()
            case "Highland BagPipes":
                AKPolyphonicNode.tuningTable.presetHighlandBagPipes()
            case "Hexany 1,45,135,225":
                AKPolyphonicNode.tuningTable.scalaFile(scalaPath!)
            case "Hexany 1,5,9,15":
                AKPolyphonicNode.tuningTable.hexany(1, 5, 9, 15)
            default:
                break
            }
        })

        addSubview(AKPropertySlider(
            property: "Morph Index",
            value: osc.index, maximum: 3,
            color: AKColor.red
        ) { index in
            osc.index = index
        })

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f s",
            value: osc.attackDuration, maximum: 2,
            color: AKColor.green
        ) { duration in
            osc.attackDuration = duration
        })

        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f s",
            value: osc.releaseDuration, maximum: 2,
            color: AKColor.green
        ) { duration in
            osc.releaseDuration = duration
        })

        addSubview(AKPropertySlider(
            property: "Detuning Offset",
            format: "%0.1f Cents",
            value:  osc.releaseDuration, minimum: -1_200, maximum: 1_200,
            color: AKColor.green
        ) { offset in
            osc.detuningOffset = offset
        })

        addSubview(AKPropertySlider(
            property: "Detuning Multiplier",
            value:  osc.detuningMultiplier, minimum: 0.5, maximum: 2.0,
            color: AKColor.green
        ) { multiplier in
            osc.detuningMultiplier = multiplier
        })

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addSubview(keyboard)

        addSubview(AKButton(title: "Go Polyphonic") {
            self.keyboard.polyphonicMode = !self.keyboard.polyphonicMode
            if self.keyboard.polyphonicMode {
                return "Go Monophonic"
            } else {
                return "Go Polyphonic"
            }
        })
    }

    func noteOn(note: MIDINoteNumber) {
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: note)
        AKLog("playing \(note) at frequency:\(frequency)")
        osc.play(noteNumber: note, velocity: 127, frequency: frequency)
    }

    func noteOff(note: MIDINoteNumber) {
        osc.stop(noteNumber: note)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

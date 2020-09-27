//: ## Mandolin
//: Physical model of a mandolin

import AudioKit

let playRate = 2.0

let mandolin = MandolinString()
mandolin.detune = 1
mandolin.bodySize = 1
var pluckPosition = 0.2

var delay = Delay(mandolin)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = Reverb(delay)

let scale: [MIDINoteNumber] = [0, 2, 4, 5, 7, 9, 11, 12]

let performance = PeriodicFunction(frequency: playRate) {
    var note1: MIDINoteNumber = scale.randomElement()!
    let octave1 = MIDINoteNumber([2, 3, 4, 5].randomElement()! * 12)
    let course1 = [1, 2, 3, 4].randomElement()!
    if AUValue.random(in: 0...10) < 1.0 { note1 += 1 }

    var note2: MIDINoteNumber = scale.randomElement()!
    let octave2 = MIDINoteNumber([2, 3, 4, 5].randomElement()! * 12)
    let course2 = [1, 2, 3, 4].randomElement()!
    if AUValue.random(in: 0...10) < 1.0 { note2 += 1 }

    if AUValue.random(in: 0...6) > 1.0 {
        mandolin.fret(noteNumber: note1 + octave1, course: course1 - 1)
        mandolin.pluck(course: course1 - 1, position: pluckPosition, velocity: 127)
    }
    if AUValue.random(in: 0...6) > 3.0 {
        mandolin.fret(noteNumber: note2 + octave2, course: course2 - 1)
        mandolin.pluck(course: course2 - 1, position: pluckPosition, velocity: 127)
    }
}

engine.output = reverb
try engine.start(withPeriodicFunctions: performance)
performance.start()


class LiveView: View {

    var detuneSlider: Slider!
    var bodySizeSlider: Slider!

    override func viewDidLoad() {
        addTitle("Mandolin")

        detuneSlider = Slider(property: "Detune",
                                value: mandolin.detune,
                                range: 0.5 ... 2,
                                format: "%0.2f"
        ) { detune in
            mandolin.detune = detune
        }
        addView(detuneSlider)

        bodySizeSlider = Slider(property: "Body Size",
                                  value: mandolin.bodySize,
                                  range: 0.2 ... 3,
                                  format: "%0.2f"
        ) { bodySize in
            mandolin.bodySize = bodySize
        }
        addView(bodySizeSlider)

        addView(Slider(property: "Pluck Position", value: pluckPosition, format: "%0.2f") { position in
            pluckPosition = position
        })

        let presets = ["Large, Resonant", "Electric Guitar-ish", "Small-Bodied, Distorted", "Acid Mandolin"]
        addView(PresetLoaderView(presets: presets) { preset in
            switch preset {
            case "Large, Resonant":
                mandolin.presetLargeResonantMandolin()
            case "Electric Guitar-ish":
                mandolin.presetElectricGuitarMandolin()
            case "Small-Bodied, Distorted":
                mandolin.presetSmallBodiedDistortedMandolin()
            case "Acid Mandolin":
                mandolin.presetAcidMandolin()
            default:
                break
            }
            self.updateUI()
        })
    }
    func updateUI() {
        detuneSlider.value = mandolin.detune
        bodySizeSlider.value = mandolin.bodySize
    }
}

import PlaygroundSupport
PlaygroundPage.current.liveView = LiveView()
PlaygroundPage.current.needsIndefiniteExecution = true

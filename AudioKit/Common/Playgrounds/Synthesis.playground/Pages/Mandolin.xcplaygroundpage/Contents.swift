//: ## Mandolin
//: Physical model of a mandolin
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
            color: AKColor.magentaColor()
        ) { detune in
            mandolin.detune = detune
        }
        addSubview(detuneSlider!)

        bodySizeSlider = AKPropertySlider(
            property: "Body Size",
            format: "%0.2f",
            value: mandolin.bodySize, minimum: 0.2, maximum: 3,
            color: AKColor.cyanColor()
        ) { bodySize in
            mandolin.bodySize = bodySize
        }
        addSubview(bodySizeSlider!)

        addSubview(AKPropertySlider(
            property: "Pluck Position",
            format: "%0.2f",
            value: pluckPosition,
            color: AKColor.redColor()
        ) { position in
            pluckPosition = position
        })


        let presets = ["Large, Resonant", "Electric Guitar-ish", "Small-Bodied, Distorted", "Acid Mandolin"]
        addSubview(AKPresetLoaderView(presets: presets) { preset in
            switch preset {
            case "Large, Resonant":
                mandolin.presetLargeResonantMandolin()
            case "Electric Guitar-ish":
                mandolin.presetElectricGuitarMandolin()
            case "Small-Bodied, Distorted":
                mandolin.presetSmallBodiedDistortedMandolin()
            case "Acid Mandolin":
                mandolin.presetAcidMandolin()
            default: break
            }
            self.updateUI()
            }
        )
    }
    func updateUI() {
        detuneSlider!.value = mandolin.detune
        bodySizeSlider!.value = mandolin.bodySize
    }
}

XCPlaygroundPage.currentPage.liveView = PlaygroundView()

AKPlaygroundLoop(frequency: playRate) {
    var note1 = scale.randomElement()
    let octave1 = (2...5).randomElement() * 12
    let course1 = (1...4).randomElement()
    if random(0, 10) < 1.0 { note1 += 1 }

    var note2 = scale.randomElement()
    let octave2 = (2...5).randomElement() * 12
    let course2 = (1...4).randomElement()
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

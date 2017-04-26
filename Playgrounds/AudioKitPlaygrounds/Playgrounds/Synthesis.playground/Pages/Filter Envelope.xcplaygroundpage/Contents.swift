//: ## Filter Envelope
//:
//: This is a pretty advanced example.
import AudioKitPlaygrounds
import AudioKit

enum SynthParameter: Int {
    case frequency, cutoff, gate
}

struct Synth {
    static var frequency: AKOperation {
        return AKOperation.parameters[SynthParameter.frequency.rawValue]
    }
    static var cutoff: AKOperation {
        return AKOperation.parameters[SynthParameter.cutoff.rawValue]
    }
    static var gate: AKOperation {
        return AKOperation.parameters[SynthParameter.gate.rawValue]
    }
}

extension AKOperationGenerator {
    var frequency: Double {
        get { return self.parameters[SynthParameter.frequency.rawValue] }
        set(newValue) { self.parameters[SynthParameter.frequency.rawValue] = newValue }
    }
    var cutoff: Double {
        get { return self.parameters[SynthParameter.cutoff.rawValue] }
        set(newValue) { self.parameters[SynthParameter.cutoff.rawValue] = newValue }
    }
    var gate: Double {
        get { return self.parameters[SynthParameter.gate.rawValue] }
        set(newValue) { self.parameters[SynthParameter.gate.rawValue] = newValue }
    }
}

let synth = AKOperationGenerator { _ in

    let oscillator = AKOperation.fmOscillator(
        baseFrequency: Synth.frequency,
        carrierMultiplier: 3,
        modulatingMultiplier: 0.7,
        modulationIndex: 2,
        amplitude: 0.1)
    let cutoff = Synth.cutoff.gatedADSREnvelope(
        gate: Synth.gate,
        attack: 0.1,
        decay: 0.01,
        sustain: 1,
        release: 0.6)

    return oscillator.moogLadderFilter(cutoffFrequency: cutoff,
        resonance: 0.9)
}

AudioKit.output = synth
AudioKit.start()
synth.parameters = [0, 1_000, 0] // Initialize the array
synth.start()

//: Setup the user interface
let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("Filter Envelope")

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: synth.cutoff, maximum: 5_000,
            color: AKColor.red
        ) { frequency in
            synth.cutoff = frequency
        })

        let keyboard = AKKeyboardView(width: playgroundWidth - 60,
                                      height: 100)
        keyboard.delegate = self
        addSubview(keyboard)
    }

    func noteOn(note: MIDINoteNumber) {
        synth.frequency = note.midiNoteToFrequency()
        synth.gate = 1
    }

    func noteOff(note: MIDINoteNumber) {
        synth.gate = 0
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

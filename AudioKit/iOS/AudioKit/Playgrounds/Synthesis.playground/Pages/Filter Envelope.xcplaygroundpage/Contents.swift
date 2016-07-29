//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Filter Envelope
//:
//: ### This is a pretty advanced example.
import XCPlayground
import AudioKit

enum SynthParameter: Int {
    case Frequency, Cutoff, Gate
}

struct Synth {
    static var frequency: AKOperation {
        return AKOperation.parameters[SynthParameter.Frequency.rawValue]
    }
    static var cutoff: AKOperation {
        return AKOperation.parameters[SynthParameter.Cutoff.rawValue]
    }
    static var gate: AKOperation {
        return AKOperation.parameters[SynthParameter.Gate.rawValue]
    }
}

extension AKOperationGenerator {
    var frequency: Double {
        get { return self.parameters[SynthParameter.Frequency.rawValue] }
        set(newValue) { self.parameters[SynthParameter.Frequency.rawValue] = newValue }
    }
    var cutoff: Double {
        get { return self.parameters[SynthParameter.Cutoff.rawValue] }
        set(newValue) { self.parameters[SynthParameter.Cutoff.rawValue] = newValue }
    }
    var gate: Double {
        get { return self.parameters[SynthParameter.Gate.rawValue] }
        set(newValue) { self.parameters[SynthParameter.Gate.rawValue] = newValue }
    }
}

let synth = AKOperationGenerator() { parameters in 
    
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
//: Set up the nodes

AudioKit.output = synth
AudioKit.start()
synth.parameters = [0, 1000, 0] // Initialize the array
synth.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("Filter Envelope")

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: synth.cutoff, maximum: 5000,
            color: AKColor.redColor()
        ) { frequency in
            synth.cutoff = frequency
        })
        
        let keyboard = AKKeyboardView(width: playgroundWidth - 60,
                                      height: 100, totalKeys: 36)
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

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

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
        return AKOperation.parameters(SynthParameter.Frequency.rawValue)
    }
    static var cutoff: AKOperation {
        return AKOperation.parameters(SynthParameter.Cutoff.rawValue)
    }
    static var gate: AKOperation {
        return AKOperation.parameters(SynthParameter.Gate.rawValue)
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

let synth = AKOperationGenerator() {

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

    return oscillator.moogLadderFilter(cutoffFrequency: cutoff, resonance: 0.9)
}

AudioKit.output = synth
AudioKit.start()
synth.parameters = [0, 1000, 0] // Initialize the array
synth.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, KeyboardDelegate {

    var cutoffFrequencyLabel: Label?

    override func setup() {
        addTitle("Filter Envelope")

        cutoffFrequencyLabel = addLabel("Cutoff Frequency: \(synth.cutoff)")
        addSlider(#selector(setCutoffFrequency), value: synth.cutoff, minimum: 0, maximum: 5000)

        let keyboard = KeyboardView(width: playgroundWidth, height: 100)
        keyboard.frame.origin.y = CGFloat(yPosition)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.addSubview(keyboard)
    }

    func noteOn(note: Int) {
        synth.frequency = note.midiNoteToFrequency()
        synth.gate = 1
    }

    func noteOff(note: Int) {
        synth.gate = 0
    }

    func setCutoffFrequency(slider: Slider) {
        synth.cutoff = Double(slider.value)
        cutoffFrequencyLabel!.text = "Cutoff Frequency: \(String(format: "%0.0f", synth.cutoff))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

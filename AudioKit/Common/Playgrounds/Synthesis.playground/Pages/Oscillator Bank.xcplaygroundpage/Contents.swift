//: ## Oscillator Bank
import PlaygroundSupport
import AudioKit

let bank = AKOscillatorBank(waveform: AKTable(.Sine),
                            attackDuration: 0.1,
                            releaseDuration: 0.1)

AudioKit.output = bank
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView?

    override func setup() {
        addTitle("Oscillator Bank")

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f",
            value: bank.attackDuration, maximum: 2,
            color: AKColor.green
        ) { duration in
            bank.attackDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Decay",
            format: "%0.3f",
            value: bank.decayDuration, maximum: 2,
            color: AKColor.cyan
        ) { duration in
            bank.decayDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Sustain Level",
            format: "%0.3f",
            value: bank.sustainLevel,
            color: AKColor.yellow
        ) { level in
            bank.sustainLevel = level
            })

        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f",
            value:  bank.releaseDuration, maximum: 2,
            color: AKColor.green
        ) { duration in
            bank.releaseDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Detuning Offset",
            format: "%0.3f",
            value:  bank.releaseDuration, minimum: -1200, maximum: 1200,
            color: AKColor.green
        ) { offset in
            bank.detuningOffset = offset
            })

        addSubview(AKPropertySlider(
            property: "Detuning Multiplier",
            format: "%0.3f",
            value:  bank.releaseDuration, minimum: 0.5, maximum: 2.0,
            color: AKColor.green
        ) { multiplier in
            bank.detuningMultiplier = multiplier
            })

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        addSubview(keyboard!)

        addSubview(AKButton(title: "Go Polyphonic") {
            self.keyboard?.polyphonicMode = !self.keyboard!.polyphonicMode
            if self.keyboard!.polyphonicMode {
                return "Go Monophonic"
            } else {
                return "Go Polyphonic"
            }
            })
    }

    func noteOn(note: MIDINoteNumber) {
        bank.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        bank.stop(noteNumber: note)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

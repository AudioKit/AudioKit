//: ## Interactive Drawbar Organ
//: Open the timeline view to use the controls this playground sets up.
//:
import PlaygroundSupport
import AudioKit

var oscillator = AKOscillatorBank()
AudioKit.output = oscillator
AudioKit.start()

let noteCount = 9
var amplitudes = Array<Double>(repeating: 0.1, count: noteCount)
var offsets = [-12, 7, 0, 12, 19, 24, 28, 31, 36]
var names = ["16", "5 1/3", "8", "4", "2 2/3", "2", "1 3/5", "1 1/3", "1"]
var baseNote = 0

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("Drawbar Organ")
        for i in 0 ..< noteCount {
            let slider = AKPropertySlider(
                property: "Amplitude \(names[i])",
                value: amplitudes[i],
                color: AKColor.green
            ) { amp in
                amplitudes[i] = amp
                }
            addSubview(slider)
        }

        let keyboard = AKKeyboardView(width: 440,
                                      height: 100)
        keyboard.delegate = self
        addSubview(keyboard)

    }

    func noteOn(note: MIDINoteNumber) {
        if note != baseNote {
            stopAll()
            baseNote = note
            startAll()
        }
    }

    func noteOff(note: MIDINoteNumber) {
        stopAll()
    }

    func stopAll() {
        for i in 0 ..< noteCount {
            oscillator.stop(noteNumber: baseNote + offsets[i])
        }
    }

    func startAll() {
        for i in 0 ..< noteCount {
            oscillator.play(noteNumber: baseNote + offsets[i], velocity: Int(amplitudes[i] * 127))
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

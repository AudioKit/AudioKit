//: ## Interactive Drawbar Organ
//: Open the timeline view to use the controls this playground sets up.
//:

import AudioKit

var oscillator = OscillatorBank()
engine.output = oscillator
try engine.start()

let noteCount = 9
var amplitudes = [Double](repeating: 0.1, count: noteCount)
var offsets = [-12, 7, 0, 12, 19, 24, 28, 31, 36]
var names = ["16", "5 1/3", "8", "4", "2 2/3", "2", "1 3/5", "1 1/3", "1"]
var baseNote: MIDINoteNumber = 0

class LiveView: View, KeyboardDelegate {

    override func viewDidLoad() {
        addTitle("Drawbar Organ")
        for i in 0 ..< noteCount {
            let slider = Slider(
                property: "Amplitude \(names[i])",
                value: amplitudes[i]
            ) { amp in
                amplitudes[i] = amp
            }
            addView(slider)
        }

        let keyboard = KeyboardView(width: 440, height: 100)
        keyboard.delegate = self
        addView(keyboard)

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
            if Int(baseNote) + offsets[i] > 0 {
                oscillator.stop(noteNumber: MIDINoteNumber(Int(baseNote) + offsets[i]))
            }
        }
    }

    func startAll() {
        for i in 0 ..< noteCount {
            oscillator.play(noteNumber: MIDINoteNumber(Int(baseNote) + offsets[i]),
                            velocity: MIDIVelocity(amplitudes[i] * 127))
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

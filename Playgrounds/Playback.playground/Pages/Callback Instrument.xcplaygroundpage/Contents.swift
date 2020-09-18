//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Callback Instrument
//:

import AudioKit

var sequencer = AppleSequencer()

// at Tempo 120, that will trigger every sixteenth note
var tempo = 120.0
var division = 1

var callbacker = MIDICallbackInstrument { status, note, _ in
    guard let midiStatus = MIDIStatusType.from(byte: status) else {
        return
    }
    if midiStatus == .noteOn {
        Log("Start Note \(note) at \(sequencer.currentPosition.seconds)")
    }
}

let clickTrack = sequencer.newTrack()
for i in 0 ..< division {
    clickTrack?.add(noteNumber: 80,
                    velocity: 100,
                    position: Duration(beats: Double(i) / Double(division)),
                    duration: Duration(beats: Double(0.1 / Double(division))))
    clickTrack?.add(noteNumber: 60,
                    velocity: 100,
                    position: Duration(beats: (Double(i) + 0.5) / Double(division)),
                    duration: Duration(beats: Double(0.1 / Double(division))))
}

clickTrack?.setMIDIOutput(callbacker.midiIn)
clickTrack?.setLoopInfo(Duration(beats: 1.0), numberOfLoops: 10)
sequencer.setTempo(tempo)

//: We must link the clock's output to AudioKit (even if we don't need the sound)
engine.output = callbacker
try engine.start()

//: Also note that when deploying this approach to an app, make sure to
//: enable "Background Modes - Audio" otherwise it won't work.


class LiveView: View {
    override func viewDidLoad() {
        addTitle("Callback Instrument")

        addView(Button(title: "Play") { _ in
            sequencer.play()
        })
        addView(Button(title: "Pause") { _ in
            sequencer.stop()
        })
        addView(Button(title: "Rewind") { _ in
            sequencer.rewind()
        })
        addLabel("Open the console log to show output.")
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

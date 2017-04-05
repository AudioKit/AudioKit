//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Callback Instrument
//:
import AudioKitPlaygrounds
import AudioKit

var sequencer = AKSequencer()

// at Tempo 120, that will trigger every sixteenth note
var tempo = 120.0
var division = 1

var callbacker = AKCallbackInstrument { status, note, _ in
    if status == .noteOn {
        print("Start Note \(note) at \(sequencer.currentPosition.seconds)")
    }
}

let clickTrack = sequencer.newTrack()
for i in 0 ..< division {
    clickTrack?.add(noteNumber: 80,
                    velocity: 100,
                    position: AKDuration(beats: Double(i) / Double(division)),
                    duration: AKDuration(beats: Double(0.1 / Double(division))))
    clickTrack?.add(noteNumber: 60,
                    velocity: 100,
                    position: AKDuration(beats: (Double(i) + 0.5) / Double(division)),
                    duration: AKDuration(beats: Double(0.1 / Double(division))))
}

clickTrack?.setMIDIOutput(callbacker.midiIn)
clickTrack?.setLoopInfo(AKDuration(beats: 1.0), numberOfLoops: 10)
sequencer.setTempo(tempo)

// We must link the clock's output to AudioKit (even if we don't need the sound)
//AudioKit.output = callbacker
//AudioKit.start()

//: Create a simple user interface

class PlaygroundView: AKPlaygroundView {
    override func setup() {
        addTitle("Callback Instrument")

        addSubview(AKButton(title: "Play") {
            sequencer.play()
            return ""
        })
        addSubview(AKButton(title: "Pause", color: AKColor.red) {
            sequencer.stop()
            return ""
        })
        addSubview(AKButton(title: "Rewind", color: AKColor.cyan) {
            sequencer.rewind()
            return ""
        })
        addLabel("Open the console log to show output.")
    }
}
sequencer.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

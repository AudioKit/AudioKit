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

var callbacker = AKMIDICallbackInstrument { statusByte, note, _ in
    guard let midiStatus = AKMIDIStatus(statusByte: statusByte) else { return }
    if midiStatus == .noteOn {
        AKLog("Start Note \(note) at \(sequencer.currentPosition.seconds)")
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
//try AudioKit.start()

//: Create a simple user interface
import AudioKitUI

class LiveView: AKLiveViewController {
    override func viewDidLoad() {
        addTitle("Callback Instrument")

        addView(AKButton(title: "Play") { _ in
            sequencer.play()
        })
        addView(AKButton(title: "Pause") { _ in
            sequencer.stop()
        })
        addView(AKButton(title: "Rewind") { _ in
            sequencer.rewind()
        })
        addLabel("Open the console log to show output.")
    }
}
sequencer.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

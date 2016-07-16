//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

import XCPlayground
import AudioKit

class SelectorClock {
    
    var sequencer = AKSequencer()
    var callbacker: AKCallbackInstrument?
    var bpm: Double
    
    init(tempo: Double = 120, division: Int = 4)
    {
        bpm = tempo
        
        callbacker = AKCallbackInstrument() { status, note, velocity in
            if note == 60 && status == .NoteOn {
                print("myClock -> Start Note 60 at  \(myClock.sequencer.currentPosition)")
            }
        }
        
        let clickTrack = sequencer.newTrack()
        for i in 0 ..< division {
            clickTrack?.add(noteNumber: 80, velocity: 100, position: AKDuration(beats: Double(i) / Double(division)) , duration: AKDuration(beats: Double(0.1 / Double(division))))
            clickTrack?.add(noteNumber: 60, velocity: 100, position: AKDuration(beats: (Double(i) + 0.5) / Double(division)) , duration: AKDuration(beats: Double(0.1 / Double(division))))
        }
        
        clickTrack?.setMIDIOutput((callbacker?.midiIn)!)
        clickTrack?.setLoopInfo(AKDuration(beats: 1.0), numberOfLoops: 10)
        sequencer.setTempo(bpm)
    }
    
    func start() {
        sequencer.rewind()
        sequencer.play()
    }
    
    func pause() {
        sequencer.stop()
    }
    
    func stop() {
        sequencer.stop()
        sequencer.rewind()
    }
    
    func play() {
        sequencer.play()
    }

    
    var tempo: Double {
        get {
            return self.bpm
        }
        set {
            sequencer.setTempo(newValue)
        }
    }
}

// at Tempo 120, that will trigger every sixteenth note
var myClock = SelectorClock(tempo: 120, division: 1)

func myFunction(status: AKMIDIStatus, note: MIDINoteNumber, velocity: MIDIVelocity) {
    if note == 80 && status == .NoteOn {
        print("myClock -> Start Note 80 at  \(myClock.sequencer.currentPosition)")
    }
}

myClock.callbacker?.callbacks.append(myFunction)

// We must link the clock's output to AudioKit (even if we don't need the sound)
AudioKit.output = myClock.callbacker

AudioKit.start()

// Then We can start the clock !
myClock.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

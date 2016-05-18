import XCPlayground
import AudioKit

typealias AKCallback = Void -> Void

public class SelectorMidiInstrument: AKMIDIInstrument {
    
    // MARK: Private Properties
    private var callbacks = [AKCallback]()
    private var _clickOsc = AKFMSynth(voiceCount: 2)
    private var _clickPlayed = false
    private var _tickNumber = 0
    
    // MARK: Public Properties
    
    var tickNumber: Int {
        get {
            return _tickNumber
        }
    }
    
    // default value is true
    // when set to false, a click note is produced
    var silent = true
    
    // Midi Pitch of the click note (should be from 10 to 110)
    var clickPitch = 60
    
    // Volume of the click note
    var clickVolume: Double {
        get {
            return _clickOsc.volume
        }
        set {
            if newValue < 0 {
                _clickOsc.volume = 0
            }
            else{
                _clickOsc.volume = newValue
            }
        }
    }
    
    func reset() {
        _tickNumber = 0
    }
    
    init() {
        super.init(instrument: _clickOsc)
        _clickOsc.attackDuration = 0.001
        _clickOsc.decayDuration = 0.01
        _clickOsc.sustainLevel = 0.001
        _clickOsc.releaseDuration=0.01
        _clickOsc.volume = 0.1
        print ("SelectorMidiInstrument initialized")
    }
    
    // add a function to be triggered each time a NoteOn is received
    func addCallback(f: Void -> Void) {
        callbacks.append(f)
        print ("callback added!")
    }
    
    // will trigger any functions attached using addCallback method
    private func triggerCallbacks() {
        _tickNumber += 1
        for callback in callbacks {
            callback()
        }
    }
    
    // Will trig in response to any noteOn Message
    override public func startNote(note: Int, withVelocity velocity: Int, onChannel channel: Int) {
        
        triggerCallbacks()
        
        if _clickOsc.volume > 0.0 &&  silent == false {
            if _clickPlayed {
                _clickOsc.stopNote(clickPitch)
            } else {
                _clickPlayed = true
            }
            
            _clickOsc.playNote(clickPitch, velocity: 100)
        }
    }
    
    override public func stopNote(note: Int, onChannel channel: Int) {
        // Does nothing, this instrument is not supposed to respond to NoteOff messages
    }
}



class SelectorClock {
    
    let midi = AKMIDI()
    private var seq = AKSequencer()
    private var clicker: SelectorMidiInstrument?
    private var bpm: Double
    
    var output:AKNode?
    
    init(tempo: Double = 120, division: Int = 4)
    {
        bpm = tempo
        clicker = SelectorMidiInstrument()
        output = clicker
        
        
        clicker?.enableMIDI(midi.client, name: "clicker midi in")
        clicker?.clickPitch = 60
        clicker?.clickVolume = 0.1
        
        
        let clickTrack = seq.newTrack()
        for i in 0 ..< (division) {
            clickTrack?.addNote(60, velocity: 100, position: Double(i) / Double(division) , duration: Double(1.0 / Double(division)))
        }
        
        clickTrack?.setMIDIOutput((clicker?.midiIn)!)
        clickTrack?.setLoopInfo(1.0, numberOfLoops: 0)
        seq.setBPM(bpm)
    }
    
    func start() {
        seq.rewind()
        clicker?.reset()
        seq.play()
    }
    
    func pause() {
        seq.stop()
    }
    
    func stop() {
        seq.stop()
        seq.rewind()
        clicker?.reset()
    }
    
    func play() {
        seq.play()
    }
    
    func addCallback(f: Void -> Void){
        clicker?.addCallback(f)
    }
    
    // Default is Zero !
    var volume: Double {
        get {
            return (clicker?.clickVolume)!
        }
        set {
            clicker?.clickVolume = newValue
            
        }
    }
    // MIDI Note Pitch (from 20 to 120)
    var pitch: Int {
        get {
            return (clicker?.clickPitch)!
        }
        set {
            clicker?.clickPitch = newValue
            
        }
    }
    
    var currentTick: Int {
        get {
            return (clicker?.tickNumber)!
        }
    }
    
    var sequence: AKSequencer {
        get {
            return seq
        }
    }
    
    var tempo: Double {
        get {
            return self.bpm
        }
        set {
            seq.setBPM(newValue)
        }
    }
    
    var silent: Bool {
        get {
            return (clicker?.silent)!
        }
        set {
            clicker?.silent = newValue
        }
    }
}


// at Tempo 120, that will trigger every sixteenth note
var myClock = SelectorClock(tempo: 120, division: 4)


// We define a function to be triggered
func aFunction() {
    print ("myClock -> tick!! \(myClock.currentTick) at  \(myClock.sequence.currentPositionInBeats)")
    
}

// We attach this function to the clock
myClock.addCallback(aFunction)

// For debug purpose, we'll make our clock make some noise
myClock.silent = false

// We can adjust the click pitch
myClock.pitch = 80

// and the click volume
myClock.volume = 0.1

// We must link the clock's output to AudioKit (even if we don't need the sound)
AudioKit.output = myClock.output

AudioKit.start()

// Then We can start the clock !
myClock.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

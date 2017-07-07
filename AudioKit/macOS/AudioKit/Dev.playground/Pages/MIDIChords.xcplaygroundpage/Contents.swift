//: MIDIChords


import AudioKit

let keys = ["C" : 0,
            "Db": 1,
            "D" : 2,
            "Eb": 3,
            "E" : 4,
            "F" : 5,
            "Gb": 6,
            "G" : 7,
            "Ab": 8,
            "A" : 9,
            "Bb": 10,
            "B" : 11]

let modes = ["major": [0, 2, 4, 5, 7, 9, 11],
             "minor": [0, 2, 3, 5, 7, 8, 10]]

let majorTriad      = [0, 4, 7]
let minorTriad      = [0, 3, 7]
let diminishedTriad = [0, 3, 6]

let chords = ["major":[majorTriad, minorTriad, minorTriad, majorTriad, majorTriad, minorTriad, diminishedTriad],
              "minor":[minorTriad, diminishedTriad, majorTriad, minorTriad, minorTriad, majorTriad, majorTriad]]

// TODO:  Add UI to change key and mode

// C Major for testing
let scale = "major"
let key:Int! = keys["C"]

let midi = AKMIDI()

midi.inputNames
midi.openInput()

class MIDIScaleQuantizer: AKMIDITransformer {
    func transform(eventList:[AKMIDIEvent]) -> [AKMIDIEvent] {
        let mode:[Int]! = modes[scale]
        var transformedList = [AKMIDIEvent]()
        
        for event in eventList {
            guard let type = event.status else {
                transformedList.append(event)
                continue
            }
            switch type {
            case .noteOn:
                if event.noteNumber != nil {
                    let normalizedNote = (Int(event.noteNumber!) - key) % 12
                    let octave = (Int(event.noteNumber!) - key) / 12
                    var inScaleNote:Int?
                    
                    for number in mode {
                        if number <= normalizedNote {
                            inScaleNote = number
                        }
                    }
                    
                    if inScaleNote != nil {
                        let newNote = octave * 12 + inScaleNote! + key!
                        transformedList.append(AKMIDIEvent(noteOn: MIDINoteNumber(newNote), velocity: event.data2, channel: event.channel!))
                    }
                }
            case .noteOff:
                if event.noteNumber != nil {
                    let normalizedNote = (Int(event.noteNumber!) - key) % 12
                    let octave = (Int(event.noteNumber!) - key) / 12
                    var inScaleNote:Int?
                    
                    for number in mode {
                        if number <= normalizedNote {
                            inScaleNote = number
                        }
                    }
                    
                    if inScaleNote != nil {
                        let newNote = octave * 12 + inScaleNote! + key!
                        transformedList.append(AKMIDIEvent(noteOff: MIDINoteNumber(newNote), velocity: 0, channel: event.channel!))
                    }
                }
            default:
                transformedList.append(event)
            }
        }
        
        return transformedList
    }
}

class MIDIChordGenerator: AKMIDITransformer {
    func transform(eventList:[AKMIDIEvent]) -> [AKMIDIEvent] {
        let mode:[Int]! = modes[scale]
        let chordSet:[[Int]]! = chords[scale]
        var transformedList = [AKMIDIEvent]()
        
        for event in eventList {
            guard let type = event.status else {
                transformedList.append(event)
                continue
            }
            switch type {
            case .noteOn:
                if event.noteNumber != nil {
                    let normalizedNote = (Int(event.noteNumber!) - key) % 12
                    let scaleDegree:Int? = mode.index(of: normalizedNote)
                    if scaleDegree != nil {
                        let chordTemplate = chordSet[scaleDegree!]

                        for note in chordTemplate {
                            AKLog("noteOn: chord note is: \(note + Int(event.noteNumber!))")
                            transformedList.append(AKMIDIEvent(noteOn: MIDINoteNumber(note + Int(event.noteNumber!)), velocity: event.data2, channel: event.channel!))
                        }
                    }
                }
            case .noteOff:
                if event.noteNumber != nil {
                    let normalizedNote = (Int(event.noteNumber!) - key) % 12
                    let scaleDegree:Int? = mode.index(of: normalizedNote)
                    if scaleDegree != nil {
                        let chordTemplate = chordSet[scaleDegree!]
                        
                        for note in chordTemplate {
                            AKLog("noteOff: chord note is: \(note + Int(event.noteNumber!))")
                            transformedList.append(AKMIDIEvent(noteOff: MIDINoteNumber(note + Int(event.noteNumber!)), velocity: event.data2, channel: event.channel!))
                        }
                    }
                }
            default:
                transformedList.append(event)
            }
        }
        
        return transformedList
    }
}
let scaleQuantizer = MIDIScaleQuantizer()
let chordGenerator = MIDIChordGenerator()

midi.addTransformer(scaleQuantizer)
midi.addTransformer(chordGenerator)

//: By defining a class that is a MIDI Listener, but with no functions overridden, we just get the default behavior which is to print to the console.
class PlaygroundMIDIListener: AKMIDIListener {
}

let listener = PlaygroundMIDIListener()

//: Add the new class to the list of MIDI listeners
midi.addListener(listener)

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


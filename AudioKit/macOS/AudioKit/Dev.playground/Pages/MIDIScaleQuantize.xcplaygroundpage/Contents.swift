//: MIDIScaleQuantize


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

// TODO:  Add UI to change key and mode
let key:Int! = keys["G"]            // G Minor for testing
let mode:[Int]! = modes["minor"]    // G Minor for testing

let midi = AKMIDI()

midi.inputNames
midi.openInput()

class MIDIScaleQuantizer: AKMIDITransformer {
    func transform(eventList:[AKMIDIEvent]) -> [AKMIDIEvent] {
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
                        let newNote = octave * 12 + inScaleNote! + key
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
                        let newNote = octave * 12 + inScaleNote! + key
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

let scaleQuantizer = MIDIScaleQuantizer()

midi.addTransformer(scaleQuantizer)

//: By defining a class that is a MIDI Listener, but with no functions overridden, we just get the default behavior which is to print to the console.
class PlaygroundMIDIListener: AKMIDIListener {
}

let listener = PlaygroundMIDIListener()

//: Add the new class to the list of MIDI listeners
midi.addListener(listener)

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


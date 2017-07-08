//: MIDIChords


import AudioKit

let sampler = AKSampler()
try sampler.loadWav("Samples/FM Piano")

let reverb = AKReverb(sampler)
reverb.loadFactoryPreset(.largeRoom)

var mixer = AKMixer(reverb)
mixer.volume = 5.0

AudioKit.output = mixer
AudioKit.start()

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

var key:Int!
var mode:[Int]!
var chordSet:[[Int]]!

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
                if event.noteNumber != nil, mode != nil, key != nil {
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
                if event.noteNumber != nil, mode != nil, key != nil {
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
        var transformedList = [AKMIDIEvent]()
        
        for event in eventList {
            guard let type = event.status else {
                transformedList.append(event)
                continue
            }
            switch type {
            case .noteOn:
                if event.noteNumber != nil, mode != nil, key != nil {
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
                if event.noteNumber != nil, mode != nil, key != nil {
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

class PlaygroundMIDIListener: AKMIDIListener {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel) {
        sampler.play(noteNumber: noteNumber)
    }
}

let listener = PlaygroundMIDIListener()

//: Add the new class to the list of MIDI listeners
midi.addListener(listener)

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        addTitle("Scale Quantizer")
        
        let keyPresets = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        addSubview(AKPresetLoaderView(presets: keyPresets) { preset in
            switch preset {
            case "C":
                key = keys["C"]
            case "Db":
                key = keys["Db"]
            case "D":
                key = keys["D"]
            case "Eb":
                key = keys["Eb"]
            case "E":
                key = keys["E"]
            case "F":
                key = keys["F"]
            case "Gb":
                key = keys["Gb"]
            case "G":
                key = keys["G"]
            case "Ab":
                key = keys["Ab"]
            case "A":
                key = keys["A"]
            case "Bb":
                key = keys["Bb"]
            case "B":
                key = keys["B"]
            default:
                break
            }
        })
        let modePresets = ["major", "minor"]
        addSubview(AKPresetLoaderView(presets: modePresets) { preset in
            switch preset {
            case "major":
                mode = modes["major"]
                chordSet = chords["major"]
            case "minor":
                mode = modes["minor"]
                chordSet = chords["minor"]
            default:
                break
            }
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()



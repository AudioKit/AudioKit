//: ## MIDI Chord Generator
//: This playground builds on the MIDI Scale Quantizer by adding a second
//: MIDITransformer which takes the quantized scale and generates chords
//: from it.  You can chain as many MIDITransformers as you want, and
//: each can take an array of MIDIEvents to process

import AudioKit

let sampler = AppleSampler()
try sampler.loadWav("Samples/FM Piano")

let reverb = Reverb(sampler)
reverb.loadFactoryPreset(.largeRoom)

var mixer = Mixer(reverb)
mixer.volume = 5.0

engine.output = mixer
try engine.start()

enum Key {
    case C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B

    static func fromString(_ string: String) -> Key {
        switch string {
        case "C":
            return .C
        case "Db":
            return .Db
        case "D":
            return .D
        case "Eb":
            return .Eb
        case "E":
            return .E
        case "F":
            return .F
        case "Gb":
            return .Gb
        case "G":
            return .G
        case "Ab":
            return .Ab
        case "A":
            return .A
        case "Bb":
            return .Bb
        case "B":
            return .B
        default:
            return .C
        }
    }
}

let majorTriad      = [0, 4, 7]
let minorTriad      = [0, 3, 7]
let diminishedTriad = [0, 3, 6]

enum Mode {
    case major, minor

    var noteOffsets: [Int] {
        switch self {
        case .major:
            return [0, 2, 4, 5, 7, 9, 11]
        case .minor:
            return [0, 2, 3, 5, 7, 8, 10]
        }
    }

    var triad: [[Int]] {
        switch self {
        case .major:
            return [majorTriad, minorTriad, minorTriad, majorTriad, majorTriad, minorTriad, diminishedTriad]
        case .minor:
            return [minorTriad, diminishedTriad, majorTriad, minorTriad, minorTriad, majorTriad, majorTriad]
        }
    }
}

var key = Key.C
var mode = Mode.major

let midi = MIDI()

midi.inputNames
midi.openInput()

class MIDIScaleQuantizer: MIDITransformer {
    func transform(eventList: [MIDIEvent]) -> [MIDIEvent] {
        var transformedList = [MIDIEvent]()

        for event in eventList {
            guard let type = event.status?.type else {
                transformedList.append(event)
                continue
            }
            switch type {
            case .noteOn:
                if event.noteNumber != nil {
                    let normalizedNote = (Int(event.noteNumber!) - key.hashValue) % 12
                    let octave = (Int(event.noteNumber!) - key.hashValue) / 12
                    var inScaleNote: Int?

                    for number in mode.noteOffsets where number <= normalizedNote {
                        inScaleNote = number
                    }

                    if inScaleNote != nil {
                        let newNote = octave * 12 + inScaleNote! + key.hashValue
                        transformedList.append(MIDIEvent(noteOn: MIDINoteNumber(newNote),
                                                           velocity: event.data[2],
                                                           channel: event.channel!))
                    }
                }
            case .noteOff:
                if event.noteNumber != nil {
                    let normalizedNote = (Int(event.noteNumber!) - key.hashValue) % 12
                    let octave = (Int(event.noteNumber!) - key.hashValue) / 12
                    var inScaleNote: Int?

                    for number in mode.noteOffsets where number <= normalizedNote {
                        inScaleNote = number
                    }

                    if inScaleNote != nil {
                        let newNote = octave * 12 + inScaleNote! + key.hashValue
                        transformedList.append(MIDIEvent(noteOff: MIDINoteNumber(newNote),
                                                           velocity: 0,
                                                           channel: event.channel!))
                    }
                }
            default:
                transformedList.append(event)
            }
        }

        return transformedList
    }
}

class MIDIChordGenerator: MIDITransformer {
    func transform(eventList: [MIDIEvent]) -> [MIDIEvent] {
        var transformedList = [MIDIEvent]()

        for event in eventList {
            guard let type = event.status?.type else {
                transformedList.append(event)
                continue
            }
            switch type {
            case .noteOn:
                if event.noteNumber != nil {
                    let normalizedNote = (Int(event.noteNumber!) - key.hashValue) % 12
                    let scaleDegree: Int? = mode.noteOffsets.index(of: normalizedNote)
                    if scaleDegree != nil {
                        let chordTemplate = mode.triad[scaleDegree!]

                        for note in chordTemplate {
                            Log("noteOn: chord note is: \(note + Int(event.noteNumber!))")
                            transformedList.append(MIDIEvent(noteOn: MIDINoteNumber(note + Int(event.noteNumber!)),
                                                               velocity: event.data[2],
                                                               channel: event.channel!))
                        }
                    }
                }
            case .noteOff:
                if event.noteNumber != nil {
                    let normalizedNote = (Int(event.noteNumber!) - key.hashValue) % 12
                    let scaleDegree: Int? = mode.noteOffsets.index(of: normalizedNote)
                    if scaleDegree != nil {
                        let chordTemplate = mode.triad[scaleDegree!]

                        for note in chordTemplate {
                            Log("noteOff: chord note is: \(note + Int(event.noteNumber!))")
                            transformedList.append(MIDIEvent(noteOff: MIDINoteNumber(note + Int(event.noteNumber!)),
                                                               velocity: event.data[2],
                                                               channel: event.channel!))
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

class PlaygroundMIDIListener: MIDIListener {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel) {
        do {
            try sampler.play(noteNumber: noteNumber)
        } catch {
            Log("Could not play")
        }
    }
}

let listener = PlaygroundMIDIListener()

//: Add the new class to the list of MIDI listeners
midi.addListener(listener)


class LiveView: View {
    override func viewDidLoad() {
        addTitle("Scale Quantizer")

        let keyPresets = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        addView(PresetLoaderView(presets: keyPresets) { preset in key = Key.fromString(preset)
        })
        let modePresets = ["major", "minor"]
        addView(PresetLoaderView(presets: modePresets) { preset in
            switch preset {
            case "major":
                mode = .major
            case "minor":
                mode = .minor
            default:
                break
            }
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

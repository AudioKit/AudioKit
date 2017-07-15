//: ## MIDI Scale Quantizer
//: This playground demonstrates how to use an AKMIDITransformer to force 
//: MIDI input to stay in a particular key
import AudioKitPlaygrounds
import AudioKit

let sampler = AKSampler()
try sampler.loadWav("Samples/FM Piano")

let reverb = AKReverb(sampler)
reverb.loadFactoryPreset(.largeRoom)

var mixer = AKMixer(reverb)
mixer.volume = 5.0

AudioKit.output = mixer
AudioKit.start()

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

//:  Add additional modes or scales to the Mode enumeration
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
}

var key = Key.C
var mode = Mode.major

let midi = AKMIDI()

midi.inputNames
midi.openInput()

class MIDIScaleQuantizer: AKMIDITransformer {
    func transform(eventList: [AKMIDIEvent]) -> [AKMIDIEvent] {
        var transformedList = [AKMIDIEvent]()

        for event in eventList {
            guard let type = event.status else {
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
                        transformedList.append(AKMIDIEvent(noteOn: MIDINoteNumber(newNote),
                                                           velocity: event.data2,
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
                        transformedList.append(AKMIDIEvent(noteOff: MIDINoteNumber(newNote),
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

let scaleQuantizer = MIDIScaleQuantizer()
midi.addTransformer(scaleQuantizer)

class PlaygroundMIDIListener: AKMIDIListener {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel) {
        sampler.play(noteNumber: noteNumber)
    }
}

let listener = PlaygroundMIDIListener()

midi.addListener(listener)

class PlaygroundView: AKPlaygroundView {
    override func setup() {
        addTitle("Scale Quantizer")

        let keyPresets = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        addSubview(AKPresetLoaderView(presets: keyPresets) { preset in key = Key.fromString(preset)
        })
        let modePresets = ["major", "minor"]
        addSubview(AKPresetLoaderView(presets: modePresets) { preset in
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
PlaygroundPage.current.liveView = PlaygroundView()

//: ## Microtonality

import AudioKitPlaygrounds
import AudioKit

// SEQUENCER PARAMETERS
let playRate: Double = 4
var transposition: Int = 0
var performanceCounter: Int = 0

// OSC
let osc = AKMorphingOscillatorBank()
osc.index = 0.8
osc.attackDuration = 0.001
osc.decayDuration = 0.25
osc.sustainLevel = 0.238_186
osc.releaseDuration = 0.125

// FILTER
let filter = AKKorgLowPassFilter(osc)
filter.cutoffFrequency = 5_500
filter.resonance = 0.2
let generatorBooster = AKBooster(filter)
generatorBooster.gain = 0.618

// DELAY
let delay = AKDelay(generatorBooster)
delay.time = 1.0 / playRate
delay.feedback = 0.618
delay.lowPassCutoff = 12_048
delay.dryWetMix = 0.75
let delayBooster = AKBooster(delay)
delayBooster.gain = 1.550_8

// REVERB
let reverb = AKCostelloReverb(delayBooster)
reverb.feedback = 0.758_816_18
reverb.cutoffFrequency = 2_222 + 1_000
let reverbBooster = AKBooster(reverb)
reverbBooster.gain = 0.746_7

// MIX
let mixer = AKMixer(generatorBooster, reverbBooster)

// MICROTONAL PRESETS
var presetDictionary = [String: () -> Void]()
let tuningTable = AKPolyphonicNode.tuningTable
presetDictionary["Ahir Bhairav"] = { tuningTable.presetPersian17NorthIndian19AhirBhairav() }
presetDictionary["Basant Mukhari"] = { tuningTable.presetPersian17NorthIndian21BasantMukhari() }
presetDictionary["Champakali"] = { tuningTable.presetPersian17NorthIndian22Champakali() }
presetDictionary["Chandra Kanada"] = { tuningTable.presetPersian17NorthIndian20ChandraKanada() }
presetDictionary["Diaphonic Tetrachhord"] = { tuningTable.presetDiaphonicTetrachord() }
presetDictionary["ET 5"] = { tuningTable.equalTemperament(notesPerOctave: 5) }
presetDictionary["Hexany (1,5,9,15)"] = { tuningTable.hexany(1, 5, 9, 15) }
presetDictionary["Hexany (3,4.,7.,10.)"] = { tuningTable.hexany(3, 4.051, 7.051, 10.051) }
presetDictionary["Highland Bagpipes"] = { tuningTable.presetHighlandBagPipes() }
presetDictionary["Madhubanti"] = { tuningTable.presetPersian17NorthIndian17Madhubanti() }
presetDictionary["Mohan Kauns"] = { tuningTable.presetPersian17NorthIndian24MohanKauns() }
presetDictionary["MOS 0.2381 9 tones"] = { tuningTable.momentOfSymmetry(generator: 0.238_186, level: 6) }
presetDictionary["MOS 0.2641 7 tones"] = { tuningTable.momentOfSymmetry(generator: 0.264_100, level: 5) }
presetDictionary["MOS 0.2926 7 tones"] = { tuningTable.momentOfSymmetry(generator: 0.292_626, level: 5, murchana: 3) }
presetDictionary["MOS 0.5833 7 tones"] = { tuningTable.momentOfSymmetry(generator: 0.583_333, level: 5) }
presetDictionary["MOS 0.5833 7 tones Mode 2"] = { tuningTable.momentOfSymmetry(generator: 0.583_333, level: 5, murchana: 2) }
presetDictionary["Nat Bhairav"] = { tuningTable.presetPersian17NorthIndian18NatBhairav() }
presetDictionary["Patdeep"] = { tuningTable.presetPersian17NorthIndian23Patdeep() }
presetDictionary["Recurrence Relation"] = { tuningTable.presetRecurrenceRelation01() }
presetDictionary["Tetrany Major (1,5,9,15)"] = { tuningTable.majorTetrany(1, 5, 9, 15) }
presetDictionary["Tetrany Minor (1,5,9,15)"] = { tuningTable.minorTetrany(1, 5, 9, 15) }

let presetArray = presetDictionary.keys.sorted()
let numTunings = presetArray.count

// SELECT A TUNING
func selectTuning(_ index: Int) {
    let i = index % numTunings
    let key = presetArray[i]
    presetDictionary[key]?()
}

// DEFAULT TUNING
selectTuning(0)

let sequencerPatterns: [String: [Int]] = [
    "Up Down": [0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1],
    "Arp 1": [1, 0, 2, 1, 3, 2, 4, 3, 5, 4, 6, 5, 7, 6, 4, 5, 3, 4, 2, 3, 1, 2, 0, 1],
    "Arp 2": [0, 2, 1, 3, 2, 4, 3, 5, 4, 6, 5, 7, 6, 8, 7, 9, 8, 6, 7, 5, 6, 4, 5, 3, 4, 2, 3, 1]]
let sequencerPatternPresets = sequencerPatterns.keys.sorted()
var sequencerPattern = sequencerPatterns[sequencerPatternPresets[0]]!

// SEQUENCER CALCULATION
func nnCalc(_ counter: Int) -> MIDINoteNumber {
    // negative time
    if counter < 0 {
        return 0
    }

    let npo = sequencerPattern.count
    var note: Int = counter % npo
    note = sequencerPattern[note]

    let rootNN: Int = 60
    let nn = MIDINoteNumber(note + rootNN + transposition)
    return nn
}

// periodic function for arpeggio
let sequencerFunction = AKPeriodicFunction(frequency: playRate) {

    // send note off for notes in the past
    let pastNN = nnCalc(performanceCounter - 2)
    osc.stop(noteNumber: pastNN)

    // send note on for notes in the present
    let presentNN = nnCalc(performanceCounter)
    let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: presentNN)
    osc.play(noteNumber: presentNN, velocity: 127, frequency: frequency)

    performanceCounter += 1
}

// Start Audio
AudioKit.output = mixer
try AudioKit.start(withPeriodicFunctions: sequencerFunction)
sequencerFunction.start()

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Microtonal Morphing Oscillator")

        addView(AKPresetLoaderView(presets: presetArray) { preset in
            presetDictionary[preset]?()
        })

        addView(AKPresetLoaderView(presets: sequencerPatternPresets) { preset in
            osc.reset()
            sequencerPattern = sequencerPatterns[preset]!
        })

        addView(AKSlider(property: "MIDI Transposition",
                         value: Double(transposition),
                         range: -16 ... 16,
                         format: "%.0f"
        ) { sliderValue in
            transposition = Int(sliderValue)
            osc.reset()
        })

        addView(AKSlider(property: "OSC Morph Index", value: osc.index, range: 0 ... 3) { sliderValue in
            osc.index = sliderValue
        })

        addView(AKSlider(property: "OSC Gain", value: generatorBooster.gain, range: 0 ... 4) { sliderValue in
            generatorBooster.gain = sliderValue
        })

        addView(AKSlider(property: "FILTER Frequency Cutoff",
                         value: filter.cutoffFrequency,
                         range: 1 ... 12_000
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
        })

        addView(AKSlider(property: "FILTER Frequency Resonance",
                         value: filter.resonance,
                         range: 0 ... 4
        ) { sliderValue in
            filter.resonance = sliderValue
        })

        addView(AKSlider(property: "OSC Amp Attack",
                         value: osc.attackDuration,
                         range: 0 ... 2,
                         format: "%0.3f s"
        ) { sliderValue in
            osc.attackDuration = sliderValue
        })

        addView(AKSlider(property: "OSC Amp Decay",
                         value: osc.decayDuration,
                         range: 0 ... 2,
                         format: "%0.3f s"
        ) { sliderValue in
            osc.decayDuration = sliderValue
        })

        addView(AKSlider(property: "OSC Amp Sustain",
                         value: osc.sustainLevel,
                         range: 0 ... 2,
                         format: "%0.3f s"
        ) { sliderValue in
            osc.sustainLevel = sliderValue
        })

        addView(AKSlider(property: "OSC Amp Release",
                         value: osc.releaseDuration,
                         range: 0 ... 2,
                         format: "%0.3f s"
        ) { sliderValue in
            osc.releaseDuration = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

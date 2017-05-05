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
typealias presetClosure = () -> Void
var presetDictionary: [String: presetClosure] = [String: presetClosure]()
let tuningTable = AKPolyphonicNode.tuningTable
presetDictionary["Madhubanti"] = {() -> Void in _ = tuningTable.presetPersian17NorthIndian17Madhubanti()}
presetDictionary["Nat Bhairav"] = {() -> Void in _ = tuningTable.presetPersian17NorthIndian18NatBhairav()}
presetDictionary["Ahir Bhairav"] = {() -> Void in _ = tuningTable.presetPersian17NorthIndian19AhirBhairav()}
presetDictionary["Chandra Kanada"] = {() -> Void in _ = tuningTable.presetPersian17NorthIndian20ChandraKanada()}
presetDictionary["Basant Mukhari"] = {() -> Void in _ = tuningTable.presetPersian17NorthIndian21BasantMukhari()}
presetDictionary["Champakali"] = {() -> Void in _ = tuningTable.presetPersian17NorthIndian22Champakali()}
presetDictionary["Patdeep"] = {() -> Void in _ = tuningTable.presetPersian17NorthIndian23Patdeep()}
presetDictionary["Mohan Kauns"] = {() -> Void in _ = tuningTable.presetPersian17NorthIndian24MohanKauns()}
presetDictionary["MOS 0.2381 9 tones"] = {() -> Void in _ = tuningTable.momentOfSymmetry(generator: 0.238_186, level: 6)}
presetDictionary["MOS 0.2641 7 tones"] = {() -> Void in _ = tuningTable.momentOfSymmetry(generator: 0.264_100, level: 5)}
presetDictionary["Tetrany Major (1,5,9,15)"] = {() -> Void in _ = tuningTable.majorTetrany(1, 5, 9, 15)}
presetDictionary["Hexany (1,5,9,15)"] = {() -> Void in _ = tuningTable.hexany(1, 5, 9, 15)}
presetDictionary["Tetrany Minor (1,5,9,15)"] = {() -> Void in _ = tuningTable.minorTetrany(1, 5, 9, 15)}
presetDictionary["Hexany (3,4.,7.,10.)"] = {() -> Void in _ = tuningTable.hexany(3, 4.051, 7.051, 10.051)}
presetDictionary["MOS 0.2926 7 tones"] = {() -> Void in _ = tuningTable.momentOfSymmetry(generator: 0.292_626, level: 5, murchana: 3)}
presetDictionary["MOS 0.5833 7 tones"] = {() -> Void in _ = tuningTable.momentOfSymmetry(generator: 0.583_333, level: 5)}
presetDictionary["MOS 0.5833 7 tones, Mode 2"] = {() -> Void in _ = tuningTable.momentOfSymmetry(generator: 0.583_333, level: 5, murchana: 2)}
presetDictionary["ET 5"] = {() -> Void in tuningTable.equalTemperament(notesPerOctave: 5)}
presetDictionary["Highland Bagpipes"] = {() -> Void in _ = tuningTable.presetHighlandBagPipes()}
presetDictionary["Diaphonic Tetrachhord"] = {() -> Void in _ = tuningTable.presetDiaphonicTetrachord()}
presetDictionary["Recurrence Relation"] = {() -> Void in _ = tuningTable.presetRecurrenceRelation01()}

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
AudioKit.start(withPeriodicFunctions: sequencerFunction)
sequencerFunction.start()

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        addTitle("Microtonal Morphing Oscillator")

        addSubview(AKPresetLoaderView(presets: presetArray) { preset in
            presetDictionary[preset]?()
        })

        addSubview(AKPresetLoaderView(presets: sequencerPatternPresets) { preset in
            osc.reset()
            sequencerPattern = sequencerPatterns[preset]!
        })

        addSubview(AKPropertySlider(
            property: "MIDI Transposition",
            format: "%.0f",
            value: Double(transposition), minimum: -16, maximum: 16,
            color: AKColor.blue
        ) { sliderValue in
            transposition = Int(sliderValue)
            osc.reset()
        })

        addSubview(AKPropertySlider(
            property: "OSC Morph Index",
            value: osc.index, minimum: 0, maximum: 3,
            color: AKColor.green
        ) { sliderValue in
            osc.index = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "OSC Gain",
            format: "%0.3f",
            value: generatorBooster.gain, minimum: 0, maximum:4,
            color: AKColor.green
        ) { sliderValue in
            generatorBooster.gain = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "FILTER Frequency Cutoff",
            value: filter.cutoffFrequency, minimum: 1, maximum: 12_000,
            color: AKColor.red
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "FILTER Frequency Resonance",
            value: filter.resonance, minimum: 0, maximum: 4,
            color: AKColor.red
        ) { sliderValue in
            filter.resonance = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "OSC Amp Attack",
            format: "%0.3f s",
            value: osc.attackDuration, maximum: 2,
            color: AKColor.green
        ) { sliderValue in
            osc.attackDuration = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "OSC Amp Decay",
            format: "%0.3f s",
            value: osc.decayDuration, maximum: 2,
            color: AKColor.green
        ) { sliderValue in
            osc.decayDuration = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "OSC Amp Sustain",
            format: "%0.3f s",
            value: osc.sustainLevel, maximum: 2,
            color: AKColor.green
        ) { sliderValue in
            osc.sustainLevel = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "OSC Amp Release",
            format: "%0.3f s",
            value: osc.releaseDuration, maximum: 2,
            color: AKColor.green
        ) { sliderValue in
            osc.releaseDuration = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Detuning Offset",
            format: "%0.1f Cents",
            value:  osc.detuningOffset, minimum: -1_200, maximum: 1_200,
            color: AKColor.green
        ) { sliderValue in
            osc.detuningOffset = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Detuning Multiplier",
            value:  osc.detuningMultiplier, minimum: 0.5, maximum: 2.0,
            color: AKColor.green
        ) { sliderValue in
            osc.detuningMultiplier = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

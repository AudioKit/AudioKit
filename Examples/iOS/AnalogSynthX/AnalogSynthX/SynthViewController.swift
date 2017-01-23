//
//  SynthViewController.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class SynthViewController: UIViewController {

    // *********************************************************
    // MARK: - Instance Properties
    // *********************************************************

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var octavePositionLabel: UILabel!
    @IBOutlet weak var oscMixKnob: KnobMedium!
    @IBOutlet weak var osc1SemitonesKnob: KnobMedium!
    @IBOutlet weak var osc2SemitonesKnob: KnobMedium!
    @IBOutlet weak var osc2DetuneKnob: KnobMedium!
    @IBOutlet weak var lfoAmtKnob: KnobMedium!
    @IBOutlet weak var lfoRateKnob: KnobMedium!
    @IBOutlet weak var crushAmtKnob: KnobMedium!
    @IBOutlet weak var delayTimeKnob: KnobMedium!
    @IBOutlet weak var delayMixKnob: KnobMedium!
    @IBOutlet weak var reverbAmtKnob: KnobMedium!
    @IBOutlet weak var reverbMixKnob: KnobMedium!
    @IBOutlet weak var cutoffKnob: KnobLarge!
    @IBOutlet weak var rezKnob: KnobSmall!
    @IBOutlet weak var subMixKnob: KnobSmall!
    @IBOutlet weak var fmMixKnob: KnobSmall!
    @IBOutlet weak var fmModKnob: KnobSmall!
    @IBOutlet weak var noiseMixKnob: KnobSmall!
    @IBOutlet weak var morphKnob: KnobSmall!
    @IBOutlet weak var masterVolKnob: KnobSmall!
    @IBOutlet weak var attackSlider: VerticalSlider!
    @IBOutlet weak var decaySlider: VerticalSlider!
    @IBOutlet weak var sustainSlider: VerticalSlider!
    @IBOutlet weak var releaseSlider: VerticalSlider!
    @IBOutlet weak var vco1Toggle: UIButton!
    @IBOutlet weak var vco2Toggle: UIButton!
    @IBOutlet weak var bitcrushToggle: UIButton!
    @IBOutlet weak var filterToggle: UIButton!
    @IBOutlet weak var delayToggle: UIButton!
    @IBOutlet weak var reverbToggle: UIButton!
    @IBOutlet weak var fattenToggle: UIButton!
    @IBOutlet weak var holdToggle: UIButton!
    @IBOutlet weak var monoToggle: UIButton!
    @IBOutlet weak var audioPlot: AKOutputWaveformPlot!
    @IBOutlet weak var plotToggle: UIButton!

    enum ControlTag: Int {
        case cutoff = 101
        case rez = 102
        case vco1Waveform = 103
        case vco2Waveform = 104
        case vco1Semitones = 105
        case vco2Semitones = 106
        case vco2Detune = 107
        case oscMix = 108
        case subMix = 109
        case fmMix = 110
        case fmMod = 111
        case lfoWaveform = 112
        case morph = 113
        case noiseMix = 114
        case lfoAmt = 115
        case lfoRate = 116
        case crushAmt = 117
        case delayTime = 118
        case delayMix = 119
        case reverbAmt = 120
        case reverbMix = 121
        case masterVol = 122
        case adsrAttack = 123
        case adsrDecay = 124
        case adsrSustain = 125
        case adsrRelease = 126
    }

    var keyboardOctavePosition: Int = 0
    var lastKey: UIButton?
    var monoMode: Bool = false
    var holdMode: Bool = false
    var midiNotesHeld = [MIDINoteNumber]()
    let blackKeys = [49, 51, 54, 56, 58, 61, 63, 66, 68, 70]

    var conductor = Conductor.sharedInstance

    // *********************************************************
    // MARK: - viewDidLoad
    // *********************************************************

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create WaveformSegmentedViews
        createWaveFormSegmentViews()

        // Set Delegates
        setDelegates()

        // Set Preset Control Values
        setDefaultValues()

        // Greeting
        statusLabel.text = String.randomGreeting()
    }

    // *********************************************************
    // MARK: - Defaults/Presets
    // *********************************************************

    func setDefaultValues() {

        // Set Preset Values
        conductor.masterVolume.volume = 1.0 // Master Volume
        conductor.core.vco1.detuningOffset = 0 // VCO1 Semitones
        conductor.core.offset2 = 0 // VCO2 Semitones
        conductor.core.vco2.detuningOffset = 0.0 // VCO2 Detune (Hz)
        conductor.core.vcoBalancer.balance = 0.5 // VCO1/VCO2 Mix
        conductor.core.subOscMixer.volume = 0.0 // SubOsc Mix
        conductor.core.fmOscMixer.volume = 0.0 // FM Mix
        conductor.core.fmOsc.modulationIndex = 0.0 // FM Modulation Amt
        conductor.core.morph = 0.0 // Morphing between waveforms
        conductor.core.noiseMixer.volume = 0.0 // Noise Mix
        conductor.filterSection.lfoAmplitude = 0.0 // LFO Amp (Hz)
        conductor.filterSection.lfoRate = 1.4 // LFO Rate
        conductor.filterSection.resonance = 0.5 // Filter Q/Rez
        conductor.multiDelay.time = 0.5 // Delay (seconds)
        conductor.multiDelay.mix = 0.5 // Dry/Wet
        conductor.reverb.feedback = 0.88 // Amt
        conductor.reverbMixer.balance = 0.4 // Dry/Wet
        conductor.midiBendRange = 2.0 // MIDI bend range in +/- semitones

        cutoffKnob.value = 0.36 // Cutoff Knob Position
        crushAmtKnob.value = 0.0 // Crusher Knob Position

        // ADSR
        conductor.core.attackDuration = 0.1
        conductor.core.decayDuration = 0.1
        conductor.core.sustainLevel = 0.66
        conductor.core.releaseDuration = 0.5

        // Update Knob & Slider UI Values
        setupKnobValues()
        setupSliderValues()

        // Update Toggle Presets
        displayModeToggled(plotToggle)

        vco1Toggled(vco1Toggle)
        vco2Toggled(vco2Toggle)
        filterToggled(filterToggle)
        delayToggled(delayToggle)
        reverbToggled(reverbToggle)
    }

    func setupKnobValues() {
        osc1SemitonesKnob.minimum = -12
        osc1SemitonesKnob.maximum = 12
        osc1SemitonesKnob.value = Double(conductor.core.offset1)

        osc2SemitonesKnob.minimum = -12
        osc2SemitonesKnob.maximum = 12
        osc2SemitonesKnob.value = Double(conductor.core.offset2)

        osc2DetuneKnob.minimum = -4
        osc2DetuneKnob.maximum = 4
        osc2DetuneKnob.value = conductor.core.vco2.detuningOffset

        subMixKnob.maximum = 1.0
        subMixKnob.value = conductor.core.subOscMixer.volume

        fmMixKnob.maximum = 1.25
        fmMixKnob.value = conductor.core.fmOscMixer.volume

        fmModKnob.maximum = 15

        morphKnob.minimum = -0.99
        morphKnob.maximum = 0.99
        morphKnob.value = conductor.core.morph

        noiseMixKnob.value = conductor.core.noiseMixer.volume

        oscMixKnob.value = conductor.core.vcoBalancer.balance

        lfoAmtKnob.maximum = 1200
        lfoAmtKnob.value = conductor.filterSection.lfoAmplitude

        lfoRateKnob.maximum = 5
        lfoRateKnob.value = conductor.filterSection.lfoRate

        rezKnob.maximum = 0.99
        rezKnob.value = conductor.filterSection.resonance

        delayTimeKnob.value = conductor.multiDelay.time
        delayMixKnob.value = conductor.multiDelay.mix

        reverbAmtKnob.maximum = 0.99
        reverbAmtKnob.value = conductor.reverb.feedback
        reverbMixKnob.value = conductor.reverbMixer.balance

        masterVolKnob.maximum = 1.0
        masterVolKnob.value = conductor.masterVolume.volume

        // Calculate Logarithmic scales based on knob position
        conductor.filterSection.cutoffFrequency = cutoffFreqFromValue(Double(cutoffKnob.value))
        conductor.bitCrusher.sampleRate = crusherFreqFromValue(Double(crushAmtKnob.value))
        conductor.bitCrusher.bitDepth = 8
    }

    func setupSliderValues() {
        attackSlider.maxValue = 1.0
        attackSlider.currentValue = CGFloat(conductor.core.attackDuration)

        decaySlider.maxValue = 1.0
        decaySlider.currentValue = CGFloat(conductor.core.decayDuration)

        sustainSlider.currentValue = CGFloat(conductor.core.sustainLevel)

        releaseSlider.maxValue = 2
        releaseSlider.currentValue = CGFloat(conductor.core.releaseDuration)
    }

    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************

    @IBAction func vco1Toggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "VCO 1 Off"
            conductor.core.vco1On = false
        } else {
            sender.isSelected = true
            statusLabel.text = "VCO 1 On"
            conductor.core.vco1On = true
        }
    }

    @IBAction func vco2Toggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "VCO 2 Off"
            conductor.core.vco2On = false
        } else {
            sender.isSelected = true
            statusLabel.text = "VCO 2 On"
            conductor.core.vco2On = true
        }
    }

    @IBAction func crusherToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "Bitcrush Off"
            conductor.bitCrusher.bypass()
        } else {
            sender.isSelected = true
            statusLabel.text = "Bitcrush On"
            conductor.bitCrusher.start()
        }
    }

    @IBAction func filterToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "Filter Off"
            conductor.filterSection.output.stop()
        } else {
            sender.isSelected = true
            statusLabel.text = "Filter On"
            conductor.filterSection.output.start()
        }
    }

    @IBAction func delayToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "Delay Off"
            conductor.multiDelayMixer.balance = 0
        } else {
            sender.isSelected = true
            statusLabel.text = "Delay On"
            conductor.multiDelayMixer.balance = 1
        }
    }

    @IBAction func reverbToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "Reverb Off"
            conductor.reverb.bypass()
        } else {
            sender.isSelected = true
            statusLabel.text = "Reverb On"
            conductor.reverb.start()
        }
    }

    @IBAction func stereoFattenToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "Stereo Fatten Off"
            conductor.fatten.dryWetMix.balance = 0
        } else {
            sender.isSelected = true
            statusLabel.text = "Stereo Fatten On"
            conductor.fatten.dryWetMix.balance = 1
        }
    }

    // Keyboard
    @IBAction func octaveDownPressed(_ sender: UIButton) {
        guard keyboardOctavePosition > -2 else {
            statusLabel.text = "How low can you go? This low."
            return
        }

        keyboardOctavePosition += -1
        octavePositionLabel.text = String(keyboardOctavePosition)
        redisplayHeldKeys()

    }

    @IBAction func octaveUpPressed(_ sender: UIButton) {
        guard keyboardOctavePosition < 3 else {
            statusLabel.text = "Captain, she can't go any higher!"
            return
        }

        keyboardOctavePosition += 1
        octavePositionLabel.text = String(keyboardOctavePosition)
        redisplayHeldKeys()
    }

    @IBAction func holdModeToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "Hold Mode Off"
            holdMode = false
            turnOffHeldKeys()
        } else {
            sender.isSelected = true
            statusLabel.text = "Hold Mode On"
            holdMode = true
        }
    }

    @IBAction func monoModeToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "Mono Mode Off"
            monoMode = false
        } else {
            sender.isSelected = true
            statusLabel.text = "Mono Mode On"
            monoMode = true
            turnOffHeldKeys()
        }
    }

    // Universal
    @IBAction func midiPanicPressed(_ sender: RoundedButton) {
        turnOffHeldKeys()
        statusLabel.text = "All Notes Off"
    }

    @IBAction func displayModeToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "Wave Display Filled Off"
            audioPlot.shouldFill = false
        } else {
            sender.isSelected = true
            statusLabel.text = "Wave Display Filled On"
            audioPlot.shouldFill = true
        }
    }


    @IBAction func cpuEfficientToggled(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            statusLabel.text = "CPU Efficient Mode Off"
        } else {
            sender.isSelected = true
            statusLabel.text = "CPU Efficient Mode On"
            // TODO: CPU Efficient CODE HERE
        }
    }

    // About App
    @IBAction func buildThisSynth(_ sender: RoundedButton) {
        openURL("http://audiokit.io/examples/AnalogSynthX")
    }

    //*****************************************************************
    // MARK: - 🎹 Key Presses
    //*****************************************************************

    @IBAction func keyPressed(_ sender: UIButton) {
        let key = sender

        // Turn off last key press in Mono
        if monoMode {
            if let lastKey = lastKey {
                turnOffKey(lastKey)
            }
        }

        // Toggle key if in Hold mode
        if holdMode {
            if midiNotesHeld.contains(midiNoteFromTag(key.tag)) {
                turnOffKey(key)
                return
            }
        }

        turnOnKey(key)
        lastKey = key
    }

    @IBAction func keyReleased(_ sender: UIButton) {
        let key = sender

        if holdMode && monoMode {
           toggleMonoKeyHeld(key)
        } else if holdMode && !monoMode {
            toggleKeyHeld(key)

        } else {
            turnOffKey(key)
        }
    }

    // *********************************************************
    // MARK: - 🎹 Key UI/UX Helpers
    // *********************************************************

    func turnOnKey(_ key: UIButton) {
        updateKeyToDownPosition(key)
        let midiNote = midiNoteFromTag(key.tag)
        statusLabel.text = "Key Pressed: \(noteNameFromMidiNote(midiNote))"
        conductor.core.play(noteNumber: midiNote, velocity: 127)
    }

    func turnOffKey(_ key: UIButton) {
        updateKeyToUpPosition(key)
        statusLabel.text = "Key Released"
        conductor.core.stop(noteNumber: midiNoteFromTag(key.tag))
    }

    func turnOffHeldKeys() {
        updateAllKeysToUpPosition()

        for note in 0...127 {
            conductor.core.stop(noteNumber: MIDINoteNumber(note))
        }
        midiNotesHeld.removeAll(keepingCapacity: false)
    }

    func updateAllKeysToUpPosition() {
        // Key up all keys shown on display
        for tag in 248...272 {
            guard let key = self.view.viewWithTag(tag) as? UIButton else {
                return
            }
            updateKeyToUpPosition(key)
        }
    }

    func redisplayHeldKeys() {

        // Determine new keyboard bounds
        let lowerMidiNote = MIDINoteNumber(48  + (keyboardOctavePosition * 12))
        let upperMidiNote = lowerMidiNote + 24
        statusLabel.text = "Keyboard Range: \(noteNameFromMidiNote(lowerMidiNote)) to \(noteNameFromMidiNote(upperMidiNote))"

        guard !monoMode else {
            turnOffHeldKeys()
            return
        }

        // Refresh keyboard
        updateAllKeysToUpPosition()

        // Check notes currently in view and turn on if held
        for note in lowerMidiNote...upperMidiNote {
            if midiNotesHeld.contains(note) {
                let keyTag = (note - (keyboardOctavePosition * 12)) + 200
                guard let key = self.view.viewWithTag(keyTag) as? UIButton else {
                    return
                }
                updateKeyToDownPosition(key)
            }
        }
    }

    func toggleKeyHeld(_ key: UIButton) {
        if let i = midiNotesHeld.index(of: midiNoteFromTag(key.tag)) {
                midiNotesHeld.remove(at: i)
        } else {
            midiNotesHeld.append(midiNoteFromTag(key.tag))
        }
    }

    func toggleMonoKeyHeld(_ key: UIButton) {
        if midiNotesHeld.contains(midiNoteFromTag(key.tag)) {
            midiNotesHeld.removeAll()
        } else {
            midiNotesHeld.removeAll()
            midiNotesHeld.append(midiNoteFromTag(key.tag))
        }
    }

    func updateKeyToUpPosition(_ key: UIButton) {
        let index = key.tag - 200
        if blackKeys.contains(index) {
            key.setImage(UIImage(named: "blackkey"), for: UIControlState())
        } else {
            key.setImage(UIImage(named: "whitekey"), for: UIControlState())
        }
    }

    func updateKeyToDownPosition(_ key: UIButton) {
        let index = key.tag - 200
        if blackKeys.contains(index) {
            key.setImage(UIImage(named: "blackkey_selected"), for: UIControlState())
        } else {
            key.setImage(UIImage(named: "whitekey_selected"), for: UIControlState())
        }
    }

    func midiNoteFromTag(_ tag: Int) -> MIDINoteNumber {
        return MIDINoteNumber((tag - 200) + (keyboardOctavePosition * 12))
    }
}


//*****************************************************************
// MARK: - 🎛 Knob Delegates
//*****************************************************************

extension SynthViewController: KnobSmallDelegate, KnobMediumDelegate, KnobLargeDelegate {

    func updateKnobValue(_ value: Double, tag: Int) {

        switch (tag) {

        // VCOs
        case ControlTag.vco1Semitones.rawValue:
            let intValue = Int(floor(value))
            statusLabel.text = "Semitones: \(intValue)"
            conductor.core.offset1 = intValue

        case ControlTag.vco2Semitones.rawValue:
            let intValue = Int(floor(value))
            statusLabel.text = "Semitones: \(intValue)"
            conductor.core.offset2 = intValue

        case ControlTag.vco2Detune.rawValue:
            statusLabel.text = "Detune: \(value.decimalString) Hz"
            conductor.core.vco2.detuningOffset = value

        case ControlTag.oscMix.rawValue:
            statusLabel.text = "OscMix: \(value.decimalString)"
            conductor.core.vcoBalancer.balance = value

        case ControlTag.morph.rawValue:
            statusLabel.text = "Morph Waveform: \(value.decimalString)"
            conductor.core.morph = value

        // Additional OSCs
        case ControlTag.subMix.rawValue:
            statusLabel.text = "Sub Osc: \(subMixKnob.knobValue.percentageString)"
            conductor.core.subOscMixer.volume = value

        case ControlTag.fmMix.rawValue:
            statusLabel.text = "FM Amt: \(fmMixKnob.knobValue.percentageString)"
            conductor.core.fmOscMixer.volume = value

        case ControlTag.fmMod.rawValue:
            statusLabel.text = "FM Mod: \(fmModKnob.knobValue.percentageString)"
            conductor.core.fmOsc.modulationIndex = value

        case ControlTag.noiseMix.rawValue:
            statusLabel.text = "Noise Amt: \(noiseMixKnob.knobValue.percentageString)"
            conductor.core.noiseMixer.volume = value

        // LFO
        case ControlTag.lfoAmt.rawValue:
            statusLabel.text = "LFO Amp: \(value.decimalString) Hz"
            conductor.filterSection.lfoAmplitude = value

        case ControlTag.lfoRate.rawValue:
            statusLabel.text = "LFO Rate: \(value.decimalString)"
            conductor.filterSection.lfoRate = value

        // Filter
        case ControlTag.cutoff.rawValue:
            let cutOffFrequency = cutoffFreqFromValue(value)
            statusLabel.text = "Cutoff: \(cutOffFrequency.decimalString) Hz"
            conductor.filterSection.cutoffFrequency = cutOffFrequency

        case ControlTag.rez.rawValue:
            statusLabel.text = "Rez: \(value.decimalString)"
            conductor.filterSection.resonance = value

        // Crusher
        case ControlTag.crushAmt.rawValue:
            let crushAmt = crusherFreqFromValue(value)
            statusLabel.text = "Bitcrush: \(crushAmt.decimalString) Sample Rate"
            conductor.bitCrusher.sampleRate = crushAmt

        // Delay
        case ControlTag.delayTime.rawValue:
            statusLabel.text = "Delay Time: \(value.decimal1000String) ms"
            conductor.multiDelay.time = value

        case ControlTag.delayMix.rawValue:
            statusLabel.text = "Delay Mix: \(value.decimalString)"
            conductor.multiDelay.mix = value

        // Reverb
        case ControlTag.reverbAmt.rawValue:
            if value == 0.99 {
                statusLabel.text = "Reverb Size: Grand Canyon!"
            } else {
                statusLabel.text = "Reverb Size: \(reverbAmtKnob.knobValue.percentageString)"
            }
            conductor.reverb.feedback = value

        case ControlTag.reverbMix.rawValue:
            statusLabel.text = "Reverb Mix: \(value.decimalString)"
            conductor.reverbMixer.balance = value

        // Master
        case ControlTag.masterVol.rawValue:
            statusLabel.text = "Master Vol: \(masterVolKnob.knobValue.percentageString)"
            conductor.masterVolume.volume = value

        default:
            break
        }
    }
}

//*****************************************************************
// MARK: - 🎚Slider Delegate (ADSR)
//*****************************************************************

extension SynthViewController: VerticalSliderDelegate {
    func sliderValueDidChange(_ value: Double, tag: Int) {

        switch (tag) {
        case ControlTag.adsrAttack.rawValue:
            statusLabel.text = "Attack: \(attackSlider.sliderValue.percentageString)"
            conductor.core.attackDuration = value

        case ControlTag.adsrDecay.rawValue:
            statusLabel.text = "Decay: \(decaySlider.sliderValue.percentageString)"
            conductor.core.decayDuration = value

        case ControlTag.adsrSustain.rawValue:
            statusLabel.text = "Sustain: \(sustainSlider.sliderValue.percentageString)"
            conductor.core.sustainLevel = value

        case ControlTag.adsrRelease.rawValue:
            statusLabel.text = "Release: \(releaseSlider.sliderValue.percentageString)"
            conductor.core.releaseDuration = value

        default:
            break
        }
    }
}

//*****************************************************************
// MARK: - WaveformSegmentedView Delegate
//*****************************************************************

extension SynthViewController: SMSegmentViewDelegate {

    // SMSegment Delegate
    func segmentView(_ segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {

        switch (segmentView.tag) {
        case ControlTag.vco1Waveform.rawValue:
            conductor.core.waveform1 = Double(index)
            statusLabel.text = "VCO1 Waveform Changed"

        case ControlTag.vco2Waveform.rawValue:
            conductor.core.waveform2 = Double(index)
            statusLabel.text = "VCO2 Waveform Changed"

        case ControlTag.lfoWaveform.rawValue:
            statusLabel.text = "LFO Waveform Changed"
            conductor.filterSection.lfoIndex = min(Double(index), 3)

        default:
            break
        }
    }
}



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
        case Cutoff = 101
        case Rez = 102
        case Vco1Waveform = 103
        case Vco2Waveform = 104
        case Vco1Semitones = 105
        case Vco2Semitones = 106
        case Vco2Detune = 107
        case OscMix = 108
        case SubMix = 109
        case FmMix = 110
        case FmMod = 111
        case LfoWaveform = 112
        case Morph = 113
        case NoiseMix = 114
        case LfoAmt = 115
        case LfoRate = 116
        case CrushAmt = 117
        case DelayTime = 118
        case DelayMix = 119
        case ReverbAmt = 120
        case ReverbMix = 121
        case MasterVol = 122
        case adsrAttack = 123
        case adsrDecay = 124
        case adsrSustain = 125
        case adsrRelease = 126
    }
    
    var keyboardOctavePosition: Int = 0
    var lastKey: UIButton?
    var monoMode: Bool = false
    var holdMode: Bool = false
    var keysHeld = [UIButton]()
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
        conductor.masterVolume.volume = 25.0 // Master Volume
        conductor.core.offset1 = 0 // VCO1 Semitones
        conductor.core.offset2 = 0 // VCO2 Semitones
        conductor.core.detune = 0.0 // VCO2 Detune (Hz)
        conductor.core.vcoBalance = 0.5 // VCO1/VCO2 Mix
        conductor.core.subOscMix = 0.0 // SubOsc Mix
        conductor.core.fmOscMix = 0.0 // FM Mix
        conductor.core.fmMod = 0.0 // FM Modulation Amt
        conductor.core.morph = 0.0 // Morphing between waveforms
        conductor.core.noiseMix = 0.0 // Noise Mix
        conductor.filterSection.lfoAmplitude = 0.0 // LFO Amp (Hz)
        conductor.filterSection.lfoRate = 1.4 // LFO Rate
        conductor.filterSection.resonance = 0.5 // Filter Q/Rez
        conductor.bitCrusher.sampleRate = 2000.0 // Bitcrush SampleRate
        conductor.multiDelay.time = 0.5 // Delay (seconds)
        conductor.multiDelay.mix = 0.5 // Dry/Wet
        conductor.reverb.feedback = 0.88 // Amt
        conductor.reverbMixer.balance = 0.4 // Dry/Wet
        cutoffKnob.value = 0.36 // Cutoff Knob Position
        
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
        osc2DetuneKnob.value = conductor.core.detune
        
        subMixKnob.maximum = 4.5
        subMixKnob.value = conductor.core.subOscMix
        
        fmMixKnob.maximum = 1.25
        fmMixKnob.value = conductor.core.fmOscMix
        
        fmModKnob.maximum = 15

        morphKnob.minimum = -0.99
        morphKnob.maximum = 0.99
        morphKnob.value = conductor.core.morph

        noiseMixKnob.value = conductor.core.noiseMix

        oscMixKnob.value = conductor.core.vcoBalance

        lfoAmtKnob.maximum = 1200
        lfoAmtKnob.value = conductor.filterSection.lfoAmplitude
        
        lfoRateKnob.maximum = 5
        lfoRateKnob.value = conductor.filterSection.lfoRate
        
        rezKnob.maximum = 0.99
        rezKnob.value = conductor.filterSection.resonance
        
        crushAmtKnob.minimum = 0
        crushAmtKnob.maximum = 1950
        crushAmtKnob.knobValue = CGFloat((crushAmtKnob.maximum - conductor.bitCrusher.sampleRate) + 50)
        
        delayTimeKnob.value = conductor.multiDelay.time
        delayMixKnob.value = conductor.multiDelay.mix
        
        reverbAmtKnob.maximum = 0.99
        reverbAmtKnob.value = conductor.reverb.feedback
        reverbMixKnob.value = conductor.reverbMixer.balance
        
        masterVolKnob.maximum = 30.0
        masterVolKnob.value = conductor.masterVolume.volume
        
        // Calculate cutoff freq based on knob position
        conductor.filterSection.cutoffFrequency = cutoffFreqFromValue(Double(cutoffKnob.value))
    }
    
    func setupSliderValues() {
        attackSlider.maxValue = 2
        attackSlider.currentValue = CGFloat(conductor.core.attackDuration)
        
        decaySlider.maxValue = 2
        decaySlider.currentValue = CGFloat(conductor.core.decayDuration)
        
        sustainSlider.currentValue = CGFloat(conductor.core.sustainLevel)
        
        releaseSlider.maxValue = 2
        releaseSlider.currentValue = CGFloat(conductor.core.releaseDuration)
    }

    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************
    
    @IBAction func vco1Toggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "VCO 1 Off"
            conductor.core.vco1On = false
        } else {
            sender.selected = true
            statusLabel.text = "VCO 1 On"
            conductor.core.vco1On = true
        }
    }
    
    @IBAction func vco2Toggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "VCO 2 Off"
            conductor.core.vco2On = false
        } else {
            sender.selected = true
            statusLabel.text = "VCO 2 On"
            conductor.core.vco2On = true
        }
    }

    @IBAction func crusherToggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "Bitcrush Off"
            conductor.bitCrusher.bypass()
        } else {
            sender.selected = true
            statusLabel.text = "Bitcrush On"
            conductor.bitCrusher.start()
        }
    }
    
    @IBAction func filterToggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "Filter Off"
            conductor.filterSection.output.stop()
        } else {
            sender.selected = true
            statusLabel.text = "Filter On"
            conductor.filterSection.output.start()
        }
    }
    
    @IBAction func delayToggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "Delay Off"
            conductor.multiDelayMixer.balance = 0
        } else {
            sender.selected = true
            statusLabel.text = "Delay On"
            conductor.multiDelayMixer.balance = 1
        }
    }
    
    @IBAction func reverbToggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "Reverb Off"
            conductor.reverb.bypass()
        } else {
            sender.selected = true
            statusLabel.text = "Reverb On"
            conductor.reverb.start()
        }
    }
    
    @IBAction func stereoFattenToggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "Stereo Fatten Off"
            conductor.fatten.mix = 0
        } else {
            sender.selected = true
            statusLabel.text = "Stereo Fatten On"
            conductor.fatten.mix = 1
        }
    }
    
    // Keyboard
    @IBAction func octaveDownPressed(sender: UIButton) {
        guard keyboardOctavePosition > -2 else { return }
        statusLabel.text = "Keyboard Octave Down"
        keyboardOctavePosition += -1
        octavePositionLabel.text = String(keyboardOctavePosition)
        // update Keyboard keys held/etc
    }
    
    @IBAction func octaveUpPressed(sender: UIButton) {
        guard keyboardOctavePosition < 3 else { return }
        statusLabel.text = "Keyboard Octave Up"
        keyboardOctavePosition += 1
        octavePositionLabel.text = String(keyboardOctavePosition)
    }
    
    @IBAction func holdModeToggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "Hold Mode Off"
            holdMode = false
            turnOffHeldKeys()
        } else {
            sender.selected = true
            statusLabel.text = "Hold Mode On"
            holdMode = true
        }
    }
    
    @IBAction func monoModeToggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "Mono Mode Off"
            monoMode = false
        } else {
            sender.selected = true
            statusLabel.text = "Mono Mode On"
            monoMode = true
            turnOffHeldKeys()
        }
    }
    
    // Universal
    @IBAction func midiPanicPressed(sender: RoundedButton) {
        statusLabel.text = "All Notes Off"
        conductor.core.panic()
    }
    
    @IBAction func displayModeToggled(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            statusLabel.text = "Wave Display Filled Off"
            audioPlot.shouldFill = false
        } else {
            sender.selected = true
            statusLabel.text = "Wave Display Filled On"
            audioPlot.shouldFill = true
        }
    }
    
    
    // About App
    @IBAction func audioKitHomepage(sender: UIButton) {
        if let url = NSURL(string: "http://audiokit.io") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func buildThisSynth(sender: RoundedButton) {
        // TODO: link to tutorial
        if let url = NSURL(string: "http://audiokit.io") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    //*****************************************************************
    // MARK: - 🎹 Key Presses
    //*****************************************************************
    
    @IBAction func keyPressed(sender: UIButton) {
        let key = sender
        
        if monoMode {
            if let lastKey = lastKey where lastKey != key {
                turnOffKey(lastKey)
            }
        }
        turnOnKey(key)
        lastKey = key
    }
    
    @IBAction func keyReleased(sender: UIButton) {
        let key = sender
        
        if holdMode && monoMode {
            if let lastKey = lastKey where lastKey != key {
                turnOffKey(lastKey)
            }
        } else if holdMode && !monoMode {
            keysHeld.append(key)
        } else {
            turnOffKey(key)
        }
        lastKey = key
    }
    
    // *********************************************************
    // MARK: - 🎹 Key UI/UX Helpers
    // *********************************************************
    
    func turnOnKey(key: UIButton) {
        let index = key.tag - 200
        
        if blackKeys.contains(index) {
            key.setImage(UIImage(named: "blackkey_selected"), forState: .Normal)
        } else {
            key.setImage(UIImage(named: "whitekey_selected"), forState: .Normal)
        }
        
        let midiNote = index + (keyboardOctavePosition * 12)
        conductor.core.playNote(midiNote, velocity: 127)
        statusLabel.text = "Key Pressed: \(returnNoteName(midiNote))"
    }
    
    func turnOffKey(key: UIButton) {
        let index = key.tag - 200
        
        if blackKeys.contains(index) {
            key.setImage(UIImage(named: "blackkey"), forState: .Normal)
        } else {
            key.setImage(UIImage(named: "whitekey"), forState: .Normal)
        }
        
        statusLabel.text = "Key Released"
        let midiNote = index + (keyboardOctavePosition * 12)
        conductor.core.stopNote(midiNote)
    }
    
    func turnOffHeldKeys() {
        for key in keysHeld {
            turnOffKey(key)
            let index = key.tag - 200
            let midiNote = index + (keyboardOctavePosition * 12)
            conductor.core.stopNote(midiNote)
        }
        if let lastKey = lastKey {
            turnOffKey(lastKey)
        }
        statusLabel.text = "Key(s) Released"
        keysHeld.removeAll(keepCapacity: false)
    }
   
}

//*****************************************************************
// MARK: - 🎛 Knob Delegates
//*****************************************************************

extension SynthViewController: KnobSmallDelegate, KnobMediumDelegate, KnobLargeDelegate {
    
    func updateKnobValue(value: Double, tag: Int) {
        
        switch (tag) {
            
        // VCOs
        case ControlTag.Vco1Semitones.rawValue:
            let intValue = Int(floor(value))
            statusLabel.text = "Semitones: \(intValue)"
            conductor.core.offset1 = intValue
            
        case ControlTag.Vco2Semitones.rawValue:
            let intValue = Int(floor(value))
            statusLabel.text = "Semitones: \(intValue)"
            conductor.core.offset2 = intValue
            
        case ControlTag.Vco2Detune.rawValue:
            statusLabel.text = "Detune: \(value.decimalString) Hz"
            conductor.core.detune = value
            
        case ControlTag.OscMix.rawValue:
            statusLabel.text = "OscMix: \(value.decimalString)"
            conductor.core.vcoBalance = value
            
        case ControlTag.Morph.rawValue:
            statusLabel.text = "Morph Waveform: \(value.decimalString)"
            conductor.core.morph = value
            
        // Additional OSCs
        case ControlTag.SubMix.rawValue:
            statusLabel.text = "Sub Osc: \(subMixKnob.knobValue.percentageString)"
            conductor.core.subOscMix = value
            
        case ControlTag.FmMix.rawValue:
            statusLabel.text = "FM Amt: \(fmMixKnob.knobValue.percentageString)"
            conductor.core.fmOscMix = value
            
        case ControlTag.FmMod.rawValue:
            statusLabel.text = "FM Mod: \(fmModKnob.knobValue.percentageString)"
            conductor.core.fmMod = value
            
        case ControlTag.NoiseMix.rawValue:
            statusLabel.text = "Noise Amt: \(noiseMixKnob.knobValue.percentageString)"
            conductor.core.noiseMix = value
            
        // LFO
        case ControlTag.LfoAmt.rawValue:
            statusLabel.text = "LFO Amp: \(value.decimalString) Hz"
            conductor.filterSection.lfoAmplitude = value
            
        case ControlTag.LfoRate.rawValue:
            statusLabel.text = "LFO Rate: \(value.decimalString)"
            conductor.filterSection.lfoRate = value
            
        // Filter
        case ControlTag.Cutoff.rawValue:
            let cutOffFrequency = cutoffFreqFromValue(value)
            statusLabel.text = "Cutoff: \(cutOffFrequency.decimalString) Hz"
            conductor.filterSection.cutoffFrequency = cutOffFrequency
            
        case ControlTag.Rez.rawValue:
            statusLabel.text = "Rez: \(value.decimalString)"
            conductor.filterSection.resonance = value
            
        // Crusher
        case ControlTag.CrushAmt.rawValue:
            let crushAmt = (crushAmtKnob.maximum - value) + 50
            statusLabel.text = "Bitcrush: \(crushAmt.decimalString) Sample Rate"
            conductor.bitCrusher.sampleRate = crushAmt
            conductor.bitCrusher.bitDepth = 8
            
        // Delay
        case ControlTag.DelayTime.rawValue:
            statusLabel.text = "Delay Time: \(value.decimal1000String) ms"
            conductor.multiDelay.time = value
            
        case ControlTag.DelayMix.rawValue:
            statusLabel.text = "Delay Mix: \(value.decimalString)"
            conductor.multiDelay.mix = value
            
        // Reverb
        case ControlTag.ReverbAmt.rawValue:
            if value == 0.99 {
                statusLabel.text = "Reverb Size: Grand Canyon!"
            } else {
                statusLabel.text = "Reverb Size: \(reverbAmtKnob.knobValue.percentageString)"
            }
            conductor.reverb.feedback = value
            
        case ControlTag.ReverbMix.rawValue:
            statusLabel.text = "Reverb Mix: \(value.decimalString)"
            conductor.reverbMixer.balance = value
            
        // Master
        case ControlTag.MasterVol.rawValue:
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
    func sliderValueDidChange(value: Double, tag: Int) {
        
        switch (tag) {
        case ControlTag.adsrAttack.rawValue:
            statusLabel.text = "Attack: \(value.decimalString) sec"
            conductor.core.attackDuration = value
            
        case ControlTag.adsrDecay.rawValue:
            statusLabel.text = "Decay: \(value.decimalString) sec"
            conductor.core.decayDuration = value
            
        case ControlTag.adsrSustain.rawValue:
            statusLabel.text = "Sustain: \(attackSlider.currentValue.percentageString)"
            conductor.core.sustainLevel = value
            
        case ControlTag.adsrRelease.rawValue:
            statusLabel.text = "Release: \(value.decimalString) sec"
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
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        
        switch (segmentView.tag) {
        case ControlTag.Vco1Waveform.rawValue:
            conductor.core.waveform1 = Double(index)
            statusLabel.text = "VCO1 Waveform Changed"
            
        case ControlTag.Vco2Waveform.rawValue:
            conductor.core.waveform2 = Double(index)
            statusLabel.text = "VCO2 Waveform Changed"
            
        case ControlTag.LfoWaveform.rawValue:
            statusLabel.text = "LFO Waveform Changed"
            conductor.filterSection.lfoIndex = min(Double(index), 3)
            
        default:
            break
        }
    }
}




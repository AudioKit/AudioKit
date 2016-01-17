//
//  SynthViewController.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
// TODO:
// * Appropriate scales for Knobs
// * Set sensible initial preset

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
    @IBOutlet weak var pwmKnob: KnobSmall!
    @IBOutlet weak var noiseMixKnob: KnobSmall!
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
        case Pwm = 113
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
        
        // Set Default Control Values
        setDefaultValues()
    }
    
    // *********************************************************
    // MARK: - Defaults/Presets
    // *********************************************************
    
    func setDefaultValues() {
        
        // Greeting
        statusLabel.text = String.randomGreeting()
        
        // Set Values
        conductor.masterVolume.volume = 10.0 // Master Volume
        conductor.core.offset1 = 0 // VCO1 Semitones
        conductor.core.offset2 = 0 // VCO2 Semitones
        conductor.core.detune = 0.0 // VCO2 Detune (Hz)
        conductor.core.vco12Mix = 0.5 // VCO1/VCO2 Mix
        conductor.core.subOscMix = 0.0 // SubOsc Mix
        conductor.core.fmOscMix = 0.0 // FM Mix
        conductor.core.fmMod = 0.0 // FM Modulation Amt
        conductor.core.pulseWidth = 0.5 // PWM
        conductor.core.noiseMix = 0.0 // Noise Mix
        conductor.filterSection.lfoAmplitude = 300.0 // LFO Amp (Hz)
        conductor.filterSection.lfoRate = 0.3 // LFO Rate
        conductor.filterSection.cutoffFrequency = 6000.0 // Filter Cutoff (Hz)
        conductor.filterSection.resonance = 0.6 // Filter Q/Rez
        
        // Set Knob Values
        osc1SemitonesKnob.value = Double(conductor.core.offset1)
        osc1SemitonesKnob.minimum = -12
        osc1SemitonesKnob.maximum = 12

        osc2SemitonesKnob.value = Double(conductor.core.offset2)
        osc2SemitonesKnob.minimum = -12
        osc2SemitonesKnob.maximum = 12

        osc2DetuneKnob.value = conductor.core.detune
        osc2DetuneKnob.minimum = -4
        osc2DetuneKnob.maximum = 4
        
        subMixKnob.value = conductor.core.subOscMix
        subMixKnob.maximum = 4.5

        fmMixKnob.value = conductor.core.fmOscMix
        fmMixKnob.maximum = 2

        fmModKnob.value = conductor.core.fmMod
        fmModKnob.maximum = 15

        pwmKnob.value = conductor.core.pulseWidth
        pwmKnob.minimum = 0.5

        noiseMixKnob.value = conductor.core.noiseMix

        oscMixKnob.value = conductor.core.vco12Mix

        lfoAmtKnob.maximum = 3000
        lfoAmtKnob.value = conductor.filterSection.lfoAmplitude

        lfoRateKnob.maximum = 5
        lfoRateKnob.value = conductor.filterSection.lfoRate
        
        cutoffKnob.value = conductor.filterSection.cutoffFrequency
        
        rezKnob.maximum = 0.99
        rezKnob.value = conductor.filterSection.resonance
      
   
        crushAmtKnob.minimum = 160
        crushAmtKnob.maximum = 5000
        crushAmtKnob.value = 2000

        delayTimeKnob.value = 0
        delayMixKnob.value = 0

        reverbAmtKnob.value = 0
        reverbMixKnob.value = 0
        
        masterVolKnob.maximum = 11.0
        masterVolKnob.value = conductor.masterVolume.volume
     
        
        // Set toggle switches
        vco1Toggled(vco1Toggle)
        vco2Toggled(vco2Toggle)
        filterToggled(filterToggle)
        displayModeToggled(plotToggle)
        //delayToggled(delayToggle)
      
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
            conductor.filterSection.mix = 0
        } else {
            sender.selected = true
            statusLabel.text = "Filter On"
            conductor.filterSection.mix = 1
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
        if let noteName = noteNames[midiNote] {
            statusLabel.text = "Key Pressed: \(noteName)"
        }
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
            statusLabel.text = "Detune: \(value.decimalFormattedString)"
            conductor.core.detune = value
            
        case ControlTag.OscMix.rawValue:
            statusLabel.text = "OscMix: \(value.decimalFormattedString)"
            conductor.core.vco12Mix = value
            
        case ControlTag.Pwm.rawValue:
            statusLabel.text = "Pulse Width: \(value.decimalFormattedString)"
            conductor.core.pulseWidth = value
            
        // Additional OSCs
        case ControlTag.SubMix.rawValue:
            statusLabel.text = "Sub Osc: \(value.decimalFormattedString)"
            conductor.core.subOscMix = value
            
        case ControlTag.FmMix.rawValue:
            statusLabel.text = "FM Amt: \(value.decimalFormattedString)"
            conductor.core.fmOscMix = value
            
        case ControlTag.FmMod.rawValue:
            statusLabel.text = "FM Mod: \(value.decimalFormattedString)"
            conductor.core.fmMod = value
            
        case ControlTag.NoiseMix.rawValue:
            statusLabel.text = "Noise Amt: \(value.decimalFormattedString)"
            conductor.core.noiseMix = value
            
        // LFO
        case ControlTag.LfoAmt.rawValue:
            statusLabel.text = "LFO Amp: \(value.decimalFormattedString)"
            conductor.filterSection.lfoAmplitude = value
            
        case ControlTag.LfoRate.rawValue:
            statusLabel.text = "LFO Rate: \(value.decimalFormattedString)"
            conductor.filterSection.lfoRate = value
            
        // Filter
        case ControlTag.Cutoff.rawValue:
            
            // Logarithmic scale to frequency
            let scaledValue = Double.scaleRangeLog(value, rangeMin: 30, rangeMax: 7000)
            let cutOffFrequency = scaledValue * 4
            statusLabel.text = "Cutoff: \(cutOffFrequency.decimalFormattedString)"
            conductor.filterSection.cutoffFrequency = cutOffFrequency
            
        case ControlTag.Rez.rawValue:
            statusLabel.text = "Rez: \(value.decimalFormattedString)"
            conductor.filterSection.resonance = value
            
        // Crusher
        case ControlTag.CrushAmt.rawValue:
            statusLabel.text = "Bitcrush: \(value.decimalFormattedString)"
            conductor.bitCrusher.sampleRate = 4000.0
            conductor.bitCrusher.bitDepth = value
            
        // Delay
        case ControlTag.DelayTime.rawValue:
            statusLabel.text = "Delay Time: \(value.decimalFormattedString)"
            conductor.multiDelay.time = value
            
        case ControlTag.DelayMix.rawValue:
            statusLabel.text = "Delay Mix: \(value.decimalFormattedString)"
            conductor.multiDelay.mix = value
            
        // Reverb
        case ControlTag.ReverbAmt.rawValue:
            statusLabel.text = "Reverb Amt: \(value.decimalFormattedString)"
            conductor.reverb.decayTimeAt0Hz = value
            
        case ControlTag.ReverbMix.rawValue:
            statusLabel.text = "Reverb Mix: \(value.decimalFormattedString)"
            conductor.reverbMixer.balance = value
            
        // Master
        case ControlTag.MasterVol.rawValue:
            statusLabel.text = "Master Vol: \(value.decimalFormattedString)"
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
            statusLabel.text = "Attack: \(value.decimalFormattedString)"
            conductor.core.attackDuration = value
            
        case ControlTag.adsrDecay.rawValue:
            statusLabel.text = "Decay: \(value.decimalFormattedString)"
            conductor.core.decayDuration = value
            
        case ControlTag.adsrSustain.rawValue:
            statusLabel.text = "Sustain: \(value.decimalFormattedString)"
            conductor.core.sustainLevel = value
            
        case ControlTag.adsrRelease.rawValue:
            statusLabel.text = "Release: \(value.decimalFormattedString)"
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
            conductor.core.selectedVCO1Waveform.changeWaveformFromIndex(index)
            statusLabel.text = "VCO1 Waveform: \(conductor.core.selectedVCO1Waveform)"
            
        case ControlTag.Vco2Waveform.rawValue:
            conductor.core.selectedVCO2Waveform.changeWaveformFromIndex(index)
            statusLabel.text = "VCO2 Waveform: \(conductor.core.selectedVCO2Waveform)"
            
        case ControlTag.LfoWaveform.rawValue:
            statusLabel.text = "LFO Waveform Changed"
            conductor.filterSection.selectedWaveform = index
            
        default:
            break
        }
    }
}




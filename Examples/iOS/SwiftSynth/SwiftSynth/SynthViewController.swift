//
//  SynthViewController.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

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
        
        // Create Waveform Segment Views
        createWaveFormSegmentViews()
        
        // Set Delegates
        setDelegates()
        
        // Set Default Control Values
        setDefaultValues()
    }
    
    func setDelegates() {
        oscMixKnob.delegate = self
        cutoffKnob.delegate = self
        rezKnob.delegate = self
        osc1SemitonesKnob.delegate = self
        osc2SemitonesKnob.delegate = self
        osc2DetuneKnob.delegate = self
        lfoAmtKnob.delegate = self
        lfoRateKnob.delegate = self
        crushAmtKnob.delegate = self
        delayTimeKnob.delegate = self
        delayMixKnob.delegate = self
        reverbAmtKnob.delegate = self
        reverbMixKnob.delegate = self
        subMixKnob.delegate = self
        fmMixKnob.delegate = self
        fmModKnob.delegate = self
        pwmKnob.delegate = self
        noiseMixKnob.delegate = self
        masterVolKnob.delegate = self
        attackSlider.delegate = self
        decaySlider.delegate = self
        sustainSlider.delegate = self
        releaseSlider.delegate = self
    }

    // *********************************************************
    // MARK: - Defaults/Presets
    // *********************************************************
    
    func setDefaultValues() {
        
        // Initial Values
        statusLabel.text = String.randomGreeting()
        
        
        osc1SemitonesKnob.knobValue = CGFloat(osc1SemitonesKnob.scaleForKnobValue(Double(conductor.core.offset1), min: -12, max: 12))
        osc2SemitonesKnob.knobValue = CGFloat(osc2SemitonesKnob.scaleForKnobValue(Double(conductor.core.offset2), min: -12, max: 12))
        osc2DetuneKnob.knobValue    = CGFloat(osc2DetuneKnob.scaleForKnobValue(Double(conductor.core.detune), min: -50, max: 50))
        subMixKnob.knobValue        = CGFloat(subMixKnob.scaleForKnobValue(Double(conductor.core.subOscMix), min: 0, max: 5))
        fmMixKnob.knobValue         = CGFloat(fmMixKnob.scaleForKnobValue(Double(conductor.core.fmOscMix), min: 0, max: 1))
        fmModKnob.knobValue         = CGFloat(fmModKnob.scaleForKnobValue(Double(conductor.core.fmMod), min: 0, max: 1))
        pwmKnob.knobValue           = CGFloat(pwmKnob.scaleForKnobValue(Double(conductor.core.pulseWidth), min: 0, max: 1))
        noiseMixKnob.knobValue      = CGFloat(noiseMixKnob.scaleForKnobValue(Double(conductor.core.noiseMix), min: 0, max: 1))
        oscMixKnob.knobValue        = CGFloat(oscMixKnob.scaleForKnobValue(Double(conductor.core.vco12Mix), min: 0, max: 1))
        
        lfoAmtKnob.knobValue        = CGFloat(lfoAmtKnob.scaleForKnobValue(Double(conductor.filterSection.lfoAmplitude), min: 0, max: 1000))
        lfoRateKnob.knobValue       = CGFloat(lfoRateKnob.scaleForKnobValue(Double(conductor.filterSection.lfoRate), min: 0, max: 5))
        
        crushAmtKnob.knobValue      = CGFloat(crushAmtKnob.scaleForKnobValue(0, min: 0, max: 1))

        cutoffKnob.knobValue        = CGFloat(cutoffKnob.scaleForKnobValue(conductor.filterSection.cutoffFrequency, min: 150.0, max: 24000.0))
        rezKnob.knobValue           = CGFloat(rezKnob.scaleForKnobValue(Double(conductor.filterSection.resonance), min: 0, max: 0.99))

        delayTimeKnob.knobValue     = CGFloat(delayTimeKnob.scaleForKnobValue(conductor.multiDelay.time, min: 0, max: 1))
        delayMixKnob.knobValue      = CGFloat(delayMixKnob.scaleForKnobValue(conductor.multiDelay.mix, min: 0, max: 1))
        
        reverbAmtKnob.knobValue     = CGFloat(reverbAmtKnob.scaleForKnobValue(conductor.reverb.feedback, min: 0, max: 0.99))
        reverbMixKnob.knobValue     = CGFloat(reverbMixKnob.scaleForKnobValue(conductor.reverbMixer.balance, min: 0, max: 1))
        
        
        // Set Osc Waveform Defaults
    }


    //*****************************************************************
    // MARK: - UI Helpers
    //*****************************************************************
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func createWaveFormSegmentViews() {
        setupOscSegmentView(8,   y: 75.0, width: 195, height: 46.0, tag: ControlTag.Vco1Waveform.rawValue, type: 0)
        setupOscSegmentView(212, y: 75.0, width: 226, height: 46.0, tag: ControlTag.Vco2Waveform.rawValue, type: 0)
        setupOscSegmentView(10,  y: 377,  width: 255, height: 46.0, tag: ControlTag.LfoWaveform.rawValue,  type: 1)
    }
    
    func setupOscSegmentView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, tag: Int, type: Int) {
        let segmentFrame = CGRect(x: x, y: y, width: width, height: height)
        let segmentView = SMSegmentView(frame: segmentFrame)
        
        if type == 0 {
            segmentView.createOscSegmentView(tag)
        } else {
            segmentView.createLfoSegmentView(tag)
        }
        
        segmentView.delegate = self
        
        // Set segment with index 0 as selected by default
        segmentView.selectSegmentAtIndex(0)
        self.view.addSubview(segmentView)
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
    
    @IBAction func ReverbToggled(sender: UIButton) {
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
    
    @IBAction func StereoFattenToggled(sender: UIButton) {
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
        guard keyboardOctavePosition > -3 else { return }
        statusLabel.text = "Keyboard Octave Down"
        keyboardOctavePosition += -1
        octavePositionLabel.text = String(keyboardOctavePosition)
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
    
    @IBAction func midiPanicPressed(sender: RoundedButton) {
        statusLabel.text = "All Notes Off"
        
        conductor.core.panic()
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
    // MARK: - 🎹 Key presses
    //*****************************************************************
    
    @IBAction func keyPressed(sender: UIButton) {
        let key = sender
        let index = sender.tag - 200
        let midiNote = index + (keyboardOctavePosition * 12)
        
        if monoMode {
            if let lastKey = lastKey where lastKey != key {
                turnOffKey(lastKey)
            }
        }
        turnOnKey(key)
        lastKey = key

        conductor.core.playNote(midiNote, velocity: 127)
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
        
        let index = sender.tag - 200
        let midiNote = index + (keyboardOctavePosition * 12)

        conductor.core.stopNote(midiNote)
    }
    
    // *********************************************************
    // MARK - Keys UI/UX Helpers
    // *********************************************************
    
    func turnOnKey(key: UIButton) {
        let index = key.tag - 200
        
        if blackKeys.contains(index) {
            key.setImage(UIImage(named: "blackkey_selected"), forState: .Normal)
        } else {
            key.setImage(UIImage(named: "whitekey_selected"), forState: .Normal)
        }
        
        let midiNote = index + (keyboardOctavePosition * 12)
        statusLabel.text = "Key Pressed: \(midiNote)"
    }
    
    func turnOffKey(key: UIButton) {
        let index = key.tag - 200
        
        if blackKeys.contains(index) {
            key.setImage(UIImage(named: "blackkey"), forState: .Normal)
        } else {
            key.setImage(UIImage(named: "whitekey"), forState: .Normal)
        }
        
        statusLabel.text = "Key Released"
        //conductor.release(index)
    }
    
    func turnOffHeldKeys() {
        for key in keysHeld {
            turnOffKey(key)
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
            let scaledValue = Double.scaleRange(value, rangeMin: -24, rangeMax: 24)
            let intValue = Int(floor(scaledValue))
            statusLabel.text = "Semitones: \(intValue)"
            conductor.core.offset1 = intValue
            
        case ControlTag.Vco2Semitones.rawValue:
            let scaledValue = Double.scaleRange(value, rangeMin: -24, rangeMax: 24)
            let intValue = Int(floor(scaledValue))
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
            
        // Additional Oscillators
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
            conductor.bitCrusher.sampleRate = Double(16000.0 * (1.0 - value))
            conductor.bitCrusher.bitDepth = Double(12 * (1.0 - value))
            
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
            conductor.reverb.feedback = value
        
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
// MARK: - Slider Delegate (ADSR)
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
// MARK: - SegmentView Delegate (waveform selector)
//*****************************************************************

extension SynthViewController: SMSegmentViewDelegate {
    
    // SMSegment Delegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        
        switch (segmentView.tag) {
        case ControlTag.Vco1Waveform.rawValue:
            statusLabel.text = "VCO1 Waveform Changed"
            conductor.core.selectedVCO1Waveform = index
            
        case ControlTag.Vco2Waveform.rawValue:
            statusLabel.text = "VCO2 Waveform Changed"
            conductor.core.selectedVCO2Waveform = index
            
        case ControlTag.LfoWaveform.rawValue:
            statusLabel.text = "LFO Waveform Changed"
            
        default:
            break
        }
    }
}


//
//  ViewController.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Cocoa

class ViewController : NSViewController {
    
    var instrument = DemoInstrument()
    //var metro = MetronomeInstrument()
//    var chorus: AKChorus?

    @IBOutlet var frequencyLabel:  AKParameterLabel!
    
    @IBOutlet var frequencySlider: AKParameterSlider!
    @IBOutlet var amplitudeSlider: AKParameterSlider!
    @IBOutlet var carrierSlider:   AKParameterSlider!
    
    @IBOutlet var filterSlider: AKParameterSlider!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        frequencyLabel.parameter  = instrument.oscillatingFrequency.frequency
        frequencySlider.parameter = instrument.oscillatingFrequency.frequency
        amplitudeSlider.parameter = instrument.oscillatingFrequency.amplitude
        carrierSlider.parameter   = instrument.fmOscillator.carrierMultiplier

//        chorus = AKChorus(input: instrument)
        
        let timesAndGains: [Float: Float] = [1.0:1.0, 2.0:0.5, 3.0:0.2]
        let delay = AKMultiTapDelay(input: instrument, timesAndGainsDictionary: timesAndGains)
        filterSlider.minValue = 0
        filterSlider.maxValue = 1
//        filterSlider.parameter = chorus!.width
        
        AKManager.sharedManager.setupAudioUnit()
    }
    
    @IBAction func revertToSines(sender: AnyObject) {
        instrument.oscillatingFrequency.waveform = AKTable.standardSineWave()
        instrument.fmOscillator.waveform         = AKTable.standardSineWave()
    }
    
    @IBAction func setModulatingMultiplier(sender: NSSlider) {
        instrument.fmOscillator.modulatingMultiplier.value = sender.floatValue
    }
    
    @IBAction func setModulationIndex(sender: NSSlider) {
        instrument.fmOscillator.modulationIndex.value = sender.floatValue
    }
    
    @IBAction func setFinalAmplitude(sender: NSSlider) {
        instrument.fmOscillator.amplitude.value = sender.floatValue
    }
    
    @IBOutlet var trigger: NSButton!
    @IBAction func trigger(sender: AnyObject) {
//        metro.playNote.trigger = true
    }
    
}

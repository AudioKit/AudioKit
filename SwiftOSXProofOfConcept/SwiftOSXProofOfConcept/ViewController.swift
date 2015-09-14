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
    
    @IBOutlet var frequencyLabel:  AKParameterLabel!
    
    @IBOutlet var frequencySlider: AKParameterSlider!
    @IBOutlet var amplitudeSlider: AKParameterSlider!
    @IBOutlet var carrierSlider:   AKParameterSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frequencyLabel.parameter  = instrument.oscillatingFrequency.frequency
        frequencySlider.parameter = instrument.oscillatingFrequency.frequency
        amplitudeSlider.parameter = instrument.oscillatingFrequency.amplitude
        carrierSlider.parameter   = instrument.fmOscillator.carrierMultiplier
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
    
    @IBAction func setFilterParameter(sender: NSSlider) {
        instrument.filter.bitDepth.value = sender.floatValue
        instrument.filter.sampleRate.value = 1000
        print(sender.floatValue)
    }
    
    
}

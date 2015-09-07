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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setFrequency(sender: NSSlider) {
        instrument.oscillatingFrequency.frequency.value = sender.floatValue
    }
    
    @IBAction func setAmplitude(sender: NSSlider) {
        instrument.oscillatingFrequency.amplitude.value = sender.floatValue
    }
    
    @IBAction func setCarrierMultiplier(sender: NSSlider) {
        instrument.fmOscillator.carrierMultiplier.value = sender.floatValue
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
}

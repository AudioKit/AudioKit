//
//  ViewController.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Cocoa

class ViewController : NSViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = AKManager.sharedManager
        manager.createInstrument()
        manager.setupAudioUnit()
    }
    
    @IBAction func setFrequency(sender: NSSlider) {
        AKManager.sharedManager.instruments.first!.oscillatingFrequency.frequency = sender.floatValue
    }
    
    @IBAction func setModulationIndex(sender: NSSlider) {
        AKManager.sharedManager.instruments.first!.fmOscillator.index = sender.floatValue*0.2
    }
}

//
//  ViewController.swift
//  SwiftFMOscillator
//
//  Created by Aurelius Prochazka on 7/5/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var frequencyLabel : UILabel = nil
    @IBOutlet var amplitudeLabel : UILabel = nil
    @IBOutlet var carrierMultiplierLabel : UILabel = nil
    @IBOutlet var modulatingMultiplierLabel : UILabel = nil
    @IBOutlet var modulationIndexLabel : UILabel = nil
    
    @IBOutlet var frequencySlider : UISlider = nil
    @IBOutlet var amplitudeSlider : UISlider = nil
    @IBOutlet var carrierMultiplierSlider : UISlider = nil
    @IBOutlet var modulatingMultiplierSlider : UISlider = nil
    @IBOutlet var modulationIndexSlider : UISlider = nil
    
    let fmSynth = FMSynth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let orchestra = AKOrchestra()
        orchestra.addInstrument(fmSynth)
        let manager = AKManager.sharedAKManager()
        manager.runOrchestra(orchestra)
        updateLabels()
        updateSliders() 
        fmSynth.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels()->Void {
        AKTools.setLabel(frequencyLabel, withProperty: fmSynth.frequency)
        AKTools.setLabel(amplitudeLabel, withProperty: fmSynth.amplitude)
        AKTools.setLabel(carrierMultiplierLabel, withProperty: fmSynth.carrierMultiplier)
        AKTools.setLabel(modulatingMultiplierLabel, withProperty: fmSynth.modulatingMultiplier)
        AKTools.setLabel(modulationIndexLabel, withProperty: fmSynth.modulationIndex)
    }
    
    func updateSliders()->Void {
        AKTools.setSlider(frequencySlider, withProperty: fmSynth.frequency)
        AKTools.setSlider(amplitudeSlider, withProperty: fmSynth.amplitude)
        AKTools.setSlider(carrierMultiplierSlider, withProperty: fmSynth.carrierMultiplier)
        AKTools.setSlider(modulatingMultiplierSlider, withProperty: fmSynth.modulatingMultiplier)
        AKTools.setSlider(modulationIndexSlider, withProperty: fmSynth.modulationIndex)
    }
    
    
    @IBAction func frequencySliderMoved(sender : AnyObject) {
        AKTools.setProperty(fmSynth.frequency, withSlider: sender as UISlider)
        updateLabels()
    }
    @IBAction func amplitudeSliderMoved(sender : AnyObject) {
        AKTools.setProperty(fmSynth.amplitude, withSlider: sender as UISlider)
        updateLabels()
    }
    @IBAction func carrierMultiplierSliderMoved(sender : AnyObject) {
        AKTools.setProperty(fmSynth.carrierMultiplier, withSlider: sender as UISlider)
        updateLabels()
    }
    @IBAction func modulatingMultiplierSliderMoved(sender : AnyObject) {
        AKTools.setProperty(fmSynth.modulatingMultiplier, withSlider: sender as UISlider)
        updateLabels()
    }
    @IBAction func modulationIndexSliderMoved(sender : AnyObject) {
        AKTools.setProperty(fmSynth.modulationIndex, withSlider: sender as UISlider)
        updateLabels()
    }
    
    
}


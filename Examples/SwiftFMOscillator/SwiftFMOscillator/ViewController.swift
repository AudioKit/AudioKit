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
        AKiOSTools.setLabel(frequencyLabel, withProperty: fmSynth.frequency)
        AKiOSTools.setLabel(amplitudeLabel, withProperty: fmSynth.amplitude)
        AKiOSTools.setLabel(carrierMultiplierLabel, withProperty: fmSynth.carrierMultiplier)
        AKiOSTools.setLabel(modulatingMultiplierLabel, withProperty: fmSynth.modulatingMultiplier)
        AKiOSTools.setLabel(modulationIndexLabel, withProperty: fmSynth.modulationIndex)
    }
    
    func updateSliders()->Void {
        AKiOSTools.setSlider(frequencySlider, withProperty: fmSynth.frequency)
        AKiOSTools.setSlider(amplitudeSlider, withProperty: fmSynth.amplitude)
        AKiOSTools.setSlider(carrierMultiplierSlider, withProperty: fmSynth.carrierMultiplier)
        AKiOSTools.setSlider(modulatingMultiplierSlider, withProperty: fmSynth.modulatingMultiplier)
        AKiOSTools.setSlider(modulationIndexSlider, withProperty: fmSynth.modulationIndex)
    }
    
    
    @IBAction func frequencySliderMoved(sender : AnyObject) {
        AKiOSTools.setProperty(fmSynth.frequency, withSlider: sender as UISlider)
        updateLabels()
    }
    @IBAction func amplitudeSliderMoved(sender : AnyObject) {
        AKiOSTools.setProperty(fmSynth.amplitude, withSlider: sender as UISlider)
        updateLabels()
    }
    @IBAction func carrierMultiplierSliderMoved(sender : AnyObject) {
        AKiOSTools.setProperty(fmSynth.carrierMultiplier, withSlider: sender as UISlider)
        updateLabels()
    }
    @IBAction func modulatingMultiplierSliderMoved(sender : AnyObject) {
        AKiOSTools.setProperty(fmSynth.modulatingMultiplier, withSlider: sender as UISlider)
        updateLabels()
    }
    @IBAction func modulationIndexSliderMoved(sender : AnyObject) {
        AKiOSTools.setProperty(fmSynth.modulationIndex, withSlider: sender as UISlider)
        updateLabels()
    }
    
    
}


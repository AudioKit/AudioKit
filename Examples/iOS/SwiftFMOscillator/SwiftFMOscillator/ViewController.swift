//
//  ViewController.swift
//  SwiftFMOscillator
//
//  Created by Aurelius Prochazka on 7/5/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var toggleSwitchClicked: UISwitch!
    
    @IBOutlet var frequencyLabel : UILabel!
    @IBOutlet var amplitudeLabel : UILabel!
    @IBOutlet var carrierMultiplierLabel : UILabel!
    @IBOutlet var modulatingMultiplierLabel : UILabel!
    @IBOutlet var modulationIndexLabel : UILabel!
    
    @IBOutlet var frequencySlider : UISlider!
    @IBOutlet var amplitudeSlider : UISlider!
    @IBOutlet var carrierMultiplierSlider : UISlider!
    @IBOutlet var modulatingMultiplierSlider : UISlider!
    @IBOutlet var modulationIndexSlider : UISlider!
    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleFMsynth(sender: AnyObject) {
        toggleSwitchClicked.on ?  fmSynth.play() : fmSynth.stop()
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
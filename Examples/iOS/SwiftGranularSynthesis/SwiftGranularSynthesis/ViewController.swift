//
//  ViewController.swift
//  SwiftGranularSynthesis
//
//  Created by Nicholas Arner on 10/3/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var toggleSwitch: UISwitch!
    @IBOutlet var mixSlider : UISlider!
    @IBOutlet var frequencySlider : UISlider!
    @IBOutlet var durationSlider : UISlider!
    @IBOutlet var densitySlider : UISlider!
    @IBOutlet var frequencyVariationSlider : UISlider!
    @IBOutlet var frequencyVariationDistributionSlider : UISlider!
    
    let granularSynth = GranularSynth();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        AKOrchestra.addInstrument(granularSynth)
        AKOrchestra.start()
        
        updateSliders()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateSliders()->Void
    {
        AKTools.setSlider(mixSlider, withProperty: granularSynth.mix)
        AKTools.setSlider(frequencySlider, withProperty: granularSynth.frequency)
        AKTools.setSlider(durationSlider,  withProperty: granularSynth.duration)
        AKTools.setSlider(densitySlider,   withProperty: granularSynth.density)
        AKTools.setSlider(frequencyVariationSlider, withProperty: granularSynth.frequencyVariation)
        AKTools.setSlider(frequencyVariationDistributionSlider, withProperty: granularSynth.frequencyVariationDistribution)
    }
    
    
    @IBAction func toggleGranularInstrument(sender: AnyObject) {
        toggleSwitch.on ?  granularSynth.play() : granularSynth.stop()
    }
    
    @IBAction func mixChanged(sender: UISlider) {
        AKTools.setProperty(granularSynth.mix, withSlider:sender)
    }
    
    @IBAction func frequencyChanged(sender: UISlider) {
        AKTools.setProperty(granularSynth.frequency, withSlider:sender)
    }
    
    @IBAction func durationChanged(sender: UISlider) {
        AKTools.setProperty(granularSynth.duration, withSlider:sender)
    }
    
    @IBAction func denistyChanged(sender: UISlider) {
        AKTools.setProperty(granularSynth.density, withSlider:sender)
    }

    @IBAction func frequencyVariationChanged(sender: UISlider) {
        AKTools.setProperty(granularSynth.frequencyVariation, withSlider:sender)
    }
    
    @IBAction func frequencyVariationDistributionChanged(sender: UISlider) {
        AKTools.setProperty(granularSynth.frequencyVariationDistribution, withSlider:sender)
    }
    

}
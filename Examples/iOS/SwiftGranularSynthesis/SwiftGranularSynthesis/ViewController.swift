//
//  ViewController.swift
//  SwiftGranularSynthesis
//
//  Created by Nicholas Arner on 10/3/14.
//  Copyright (c) 2014 Nicholas Arner. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    @IBOutlet weak var toggleSwitchClicked: UISwitch!
    @IBOutlet var averageGrainDurationControl : UISlider!
    @IBOutlet var grainDensityControl : UISlider!
    @IBOutlet var freqDevControl : UISlider!
    @IBOutlet var amplitudeControl : UISlider!
    
    let granularSynth = GranularSynth();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let orchestra = AKOrchestra()
        orchestra.addInstrument(granularSynth)
        let manager = AKManager.sharedAKManager()
        manager.runOrchestra(orchestra)
        updateSliders()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateSliders()->Void
    {
        AKTools.setSlider(averageGrainDurationControl, withProperty: granularSynth.averageGrainDuration)
        AKTools.setSlider(grainDensityControl, withProperty: granularSynth.grainDensity)
        AKTools.setSlider(freqDevControl, withProperty: granularSynth.granularFrequencyDeviation)
        AKTools.setSlider(amplitudeControl, withProperty: granularSynth.granularAmplitude)
    }
    
    
    @IBAction func toggleGranularInstrument(sender: AnyObject) {
        toggleSwitchClicked.on ?  granularSynth.play() : granularSynth.stop()
    }
    

    @IBAction func averageGrainDurationControl(sender: AnyObject) {
        AKTools.setProperty(granularSynth.averageGrainDuration, withSlider: sender as UISlider)
    }
    
    @IBAction func grainDensityControl(sender: AnyObject) {
        AKTools.setProperty(granularSynth.grainDensity, withSlider: sender as UISlider)
    }
    
    @IBAction func freqDevControl(sender: AnyObject) {
        AKTools.setProperty(granularSynth.granularFrequencyDeviation, withSlider: sender as UISlider)
    }
    
    @IBAction func amplitudeControl(sender: AnyObject) {
        AKTools.setProperty(granularSynth.granularAmplitude, withSlider: sender as UISlider)
    }
}
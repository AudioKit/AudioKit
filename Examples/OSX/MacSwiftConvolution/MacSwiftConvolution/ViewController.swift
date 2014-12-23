//
//  ViewController.swift
//  MacSwiftConvolution
//
//  Created by Aurelius Prochazka on 11/4/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var dryWetSlider: NSSlider!
    @IBOutlet var dishStairwellSlider: NSSlider!

    let conv = ConvolutionInstrument()
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        AKOrchestra.addInstrument(conv)
        AKOrchestra.start()
        
        updateSliders()
    }
    
    func updateSliders()->Void{
        AKTools.setSlider(dryWetSlider, withProperty: conv.dryWetBalance)
        AKTools.setSlider(dishStairwellSlider, withProperty: conv.dishWellBalance)
    }
    
    @IBAction func start(sender: AnyObject) {
        conv.play()
    }
    
    @IBAction func stop(sender: AnyObject) {
        conv.stop()
    }
    
    @IBAction func changeDryWet(sender: AnyObject) {
        AKTools.setProperty(conv.dryWetBalance, withSlider: sender as NSSlider)
    }
    
    @IBAction func changeDishWell(sender: AnyObject) {
        AKTools.setProperty(conv.dishWellBalance, withSlider: sender as NSSlider)
    }
}
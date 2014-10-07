//
//  ViewController.swift
//  SwiftConvolution
//
//  Created by Nicholas Arner on 10/7/14.
//  Copyright (c) 2014 Nicholas Arner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var changeDryWet: UISlider!
    @IBOutlet weak var dryWetBalance: UISlider!
    
    let conv = ConvolutionInstrument()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let orchestra = AKOrchestra()
        orchestra.addInstrument(conv)
        let manager = AKManager.sharedAKManager()
        manager.runOrchestra(orchestra)
        updateSliders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func updateSliders()->Void{
        AKTools.setSlider(changeDryWet, withProperty: conv.dryWetBalance)
//        AKTools.setSlider(changeDishWell, withProperty: conv.dishWellBalance)
    }

    
    @IBAction func start(sender: AnyObject) {
        conv.play()
    }

    
    @IBAction func stop(sender: AnyObject) {
        conv.stop()
    }
    
    
    @IBAction func changeDryWet(sender: AnyObject) {
        AKTools.setProperty(conv.dryWetBalance, withSlider: sender as UISlider)
    }

    @IBAction func changeDishWell(sender: AnyObject) {
        AKTools.setProperty(conv.dishWellBalance, withSlider: sender as UISlider)
    }
}
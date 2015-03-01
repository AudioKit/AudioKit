//
//  ViewController.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    
    let tambourine    = Tambourine()
    let fmSynthesizer = FMSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the vFMSynthesizeriew, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.vidwDidApper()
        
        let tambourine = AKTambourine()
        AKOrchestra.addInstrument(tambourine)
        
        let fmSynthesizer = FMSynthesizer()
        AKOrchestra.addInstrument(fmSynthesizer)
        
        AKOrchestra .start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear()
        AKOrchestra.reset()
        AKManager.sharedManager(stop)
    }

}


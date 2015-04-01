//
//  ViewController.swift
//  HelloWorld
//
//  Created by Nicholas Arner on 2/22/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // STEP 1 : Set up an instance variable for the instrument
    let instrument = AKInstrument()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // STEP 2 : Define the instrument as a simple oscillator
        let oscillator = AKOscillator()
        instrument.setAudioOutput(oscillator)

        // STEP 3 : Add the instrument to the orchestra and start the orchestra
        AKOrchestra.addInstrument(instrument)
    }

    // STEP 4 : React to a button press on the Storyboard UI by
    //          playing or stopping the instrument and updating the button text.
    @IBAction func toggleSound(sender: UIButton){
        if !(sender.titleLabel?.text == "Stop") {
            instrument.play()
            sender.setTitle("Stop", forState: UIControlState.Normal)
        } else {
            instrument.stop()
            sender.setTitle("Play Sine Wave at 440HZ", forState: UIControlState.Normal)
        }
    }
}

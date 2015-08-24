//
//  ViewController.swift
//  HelloWorld
//
//  Created by Nicholas Arner on 2/28/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // STEP 1 : Set up an instance variable for the instrument
    let instrument = AKInstrument()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // STEP 2 : Define the instrument as a simple oscillator
        let oscillator = AKOscillator()
        instrument.connect(oscillator)
        instrument.connect(AKAudioOutput(input: oscillator))

        // STEP 3 : Add the instrument to the orchestra and start the orchestra
        AKOrchestra.addInstrument(instrument)
        AKOrchestra.start()
    }

    // STEP 4 : React to a button press on the Storyboard UI by
    //          playing or stopping the instrument and updating the button text.
    @IBAction func toggleSound(sender: NSButton){
        if !(sender.title == "Stop") {
            instrument.play()
            sender.title = "Stop"
        } else {
            instrument.stop()
            sender.title = "Play Sine Wave at 440HZ"
        }
    }
}


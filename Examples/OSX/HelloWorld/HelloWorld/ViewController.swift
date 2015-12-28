//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController {

    let audiokit = AKManager.sharedInstance
    var oscillator = AKOscillator()

    @IBOutlet var plot: AKOutputWaveformPlot!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        audiokit.audioOutput = oscillator
        audiokit.start()
    }
    
    @IBAction func toggleSound(sender: NSButton) {
        if oscillator.amplitude >  0 {
            oscillator.amplitude = 0.0
            sender.title = "Play Sine Wave"
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            sender.title = "Stop Sine Wave at \(Int(oscillator.frequency))Hz"
        }
        sender.setNeedsDisplay()
    }
}


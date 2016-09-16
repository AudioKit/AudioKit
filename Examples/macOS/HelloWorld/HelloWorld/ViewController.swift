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

    var oscillator = AKOscillator()

    @IBOutlet var plot: AKOutputWaveformPlot!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AudioKit.output = oscillator
        AudioKit.start()
    }
    
    @IBAction func toggleSound(_ sender: NSButton) {
        if oscillator.isPlaying {
            oscillator.stop()
            sender.title = "Play Sine Wave"
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
            sender.title = "Stop Sine Wave at \(Int(oscillator.frequency))Hz"
        }
        sender.setNeedsDisplay()
    }
}


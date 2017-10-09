//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import Cocoa

class ViewController: NSViewController {

    var oscillator = AKOscillator()
    var oscillator2 = AKOscillator()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        AudioKit.output = AKMixer(oscillator, oscillator2)
        AudioKit.start()
    }

    @IBAction func toggleSound(_ sender: NSButton) {
        if oscillator.isPlaying {
            oscillator.stop()
            oscillator2.stop()
            sender.title = "Play Sine Waves"
        } else {
            oscillator.amplitude = random(in: 0.5 ... 1)
            oscillator.frequency = random(in: 220 ... 880)
            oscillator.start()
            oscillator2.amplitude = random(in: 0.5 ... 1)
            oscillator2.frequency = random(in: 220 ... 880)
            oscillator2.start()
            sender.title = "Stop \(Int(oscillator.frequency))Hz & \(Int(oscillator2.frequency))Hz"
        }
        sender.setNeedsDisplay()
    }
}

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

    var oscillator1 = AKOscillator()
    var oscillator2 = AKOscillator()
    var mixer = AKMixer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        mixer = AKMixer(oscillator1, oscillator2)

        // Cut the volume in half since we have two oscillators
        mixer.volume = 0.5
        AudioKit.output = mixer
        AudioKit.start()
    }

    @IBAction func toggleSound(_ sender: NSButton) {
        if oscillator1.isPlaying {
            oscillator1.stop()
            oscillator2.stop()
            sender.title = "Play Sine Waves"
        } else {
            oscillator1.amplitude = random(in: 0.5 ... 1)
            oscillator1.frequency = random(in: 220 ... 880)
            oscillator1.start()
            oscillator2.amplitude = random(in: 0.5 ... 1)
            oscillator2.frequency = random(in: 220 ... 880)
            oscillator2.start()
            sender.title = "Stop \(Int(oscillator1.frequency))Hz & \(Int(oscillator2.frequency))Hz"
        }
        sender.setNeedsDisplay()
    }
}

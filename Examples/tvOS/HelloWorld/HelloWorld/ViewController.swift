//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class ViewController: UIViewController {

    var oscillator = AKOscillator()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        AudioKit.output = oscillator
        AudioKit.start()
    }

    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator.isPlaying {
            oscillator.stop()
            sender.setTitle("Play Sine Wave", for: UIControlState())
        } else {
            oscillator.amplitude = random(in: 0.5 ... 1)
            oscillator.frequency = random(in: 220 ... 880)
            oscillator.start()
            sender.setTitle("Stop Sine Wave at \(Int(oscillator.frequency))Hz", for: .normal)
        }
        sender.setNeedsDisplay()
    }

}

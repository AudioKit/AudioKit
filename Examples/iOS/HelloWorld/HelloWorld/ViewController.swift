//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    let audiokit = AKManager.sharedInstance
    let oscillator = AKOscillator()

    override func viewDidLoad() {
        super.viewDidLoad()

        audiokit.audioOutput = oscillator
        audiokit.start()
    }
    
    
    @IBAction func toggleSound(sender: UIButton) {
        if oscillator.amplitude >  0.5 {
            print("1")
            oscillator.amplitude = 0
            sender.setTitle("Play Sine Wave at 440Hz", forState: .Normal)
        } else {
            print("0")
            oscillator.amplitude = 1
            sender.setTitle("Stop Sine Wave at 440Hz", forState: .Normal)
        }
        sender.setNeedsDisplay()
    }

}


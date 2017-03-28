//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController {

    var oscillator = AKOscillator()
    var oscillator2 = AKOscillator()

    override func viewDidLoad() {
        super.viewDidLoad()

        AudioKit.output = AKMixer(oscillator, oscillator2)
        AudioKit.start()
    }

    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator.isPlaying {
            oscillator.stop()
            oscillator2.stop()
            sender.setTitle("Play Sine Waves", for: .normal)
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
            oscillator2.amplitude = random(0.5, 1)
            oscillator2.frequency = random(220, 880)
            oscillator2.start()
            sender.setTitle("Stop \(Int(oscillator.frequency))Hz & \(Int(oscillator2.frequency))Hz", for: .normal)
        }
    }

}

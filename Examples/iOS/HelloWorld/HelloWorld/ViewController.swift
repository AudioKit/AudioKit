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

    var oscillator1 = AKOscillator()
    var oscillator2 = AKOscillator()
    var mixer = AKMixer()

    override func viewDidLoad() {
        super.viewDidLoad()

        mixer = AKMixer(oscillator1, oscillator2)
        mixer.volume = 0.5
        AudioKit.output = mixer
        AudioKit.start()
    }

    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator1.isPlaying {
            oscillator1.stop()
            oscillator2.stop()
            sender.setTitle("Play Sine Waves", for: .normal)
        } else {
            oscillator1.frequency = random(220, 880)
            oscillator1.start()
            oscillator2.frequency = random(220, 880)
            oscillator2.start()
            sender.setTitle("Stop \(Int(oscillator1.frequency))Hz & \(Int(oscillator2.frequency))Hz", for: .normal)
        }
    }

}

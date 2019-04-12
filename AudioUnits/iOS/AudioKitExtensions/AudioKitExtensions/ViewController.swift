//
//  ViewController.swift
//  AudioKitExtensions
//
//  Created by Aurelius Prochazka on 7/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                AUAudioUnit.registerSubclass(AKOscillatorBankAudioUnit.self, as: AKOscillatorBank.ComponentDescription, name: "AudioKit: Oscillator Bank", version: UINT32_MAX)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

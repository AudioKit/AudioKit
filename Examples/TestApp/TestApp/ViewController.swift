//
//  ViewController.swift
//  TestApp
//
//  Created by Aurelius Prochazka on 9/29/15.
//
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    
    let audiokit = AKManager.sharedManager

    override func viewDidLoad() {
        super.viewDidLoad()
        let input  = AKMicrophone()
        let delay  = AKAUDelay(input)
        let moog   = AKMoogLadder(delay)
        let reverb = AKAUReverb(moog)
        audiokit.audioOutput = reverb
        audiokit.start()
    }
}


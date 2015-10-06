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
    let input = AKMicrophone()
    var delay:  AKAUDelay?
    var moog:   AKMoogLadder?
    var reverb: AKAUReverb?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delay  = AKAUDelay(input)
        moog   = AKMoogLadder(delay!)
        reverb = AKAUReverb(moog!)
        if let reverb = reverb { reverb.loadFactoryPreset(.Plate) }
        audiokit.audioOutput = reverb
        audiokit.start()
    }
    
    @IBAction func changeReverb(sender: UISlider) {
        guard let reverb = reverb else { return }
        reverb.wetDryMix = 100.0 * sender.value
    }
    @IBAction func changeDelayTime(sender: UISlider) {
        if let delay = delay { delay.delayTime = NSTimeInterval(sender.value) }
    }
    @IBAction func changeCutoff(sender: UISlider) {
        guard let moog = moog else { return }
        moog.cutoffFrequency = sender.value * 10000.0
    }
    @IBAction func changeResonance(sender: UISlider) {
        guard let moog = moog else { return }
        moog.resonance = sender.value * 100.0

    }
}


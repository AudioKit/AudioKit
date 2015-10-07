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
    
    let audiokit = AKManager.sharedInstance
    let input = AKMicrophone()
    var delay:  AKAUDelay?
    var moog:   AKMoogLadder?
    var allpass: AKFlatFrequencyResponseReverb?
    var reverb: AKAUReverb?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delay   = AKAUDelay(input)
        moog    = AKMoogLadder(delay!)
        allpass = AKFlatFrequencyResponseReverb(moog!, loopDuration: 0.1)
        reverb  = AKAUReverb(allpass!)
        if let reverb = reverb { reverb.loadFactoryPreset(.Plate) }
        audiokit.audioOutput = reverb!
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
    @IBAction func changeReverbDuration(sender: UISlider) {
        guard let allpass = allpass else { return }
        allpass.reverbDuration = sender.value * 5.0
    }
}


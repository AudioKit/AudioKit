//
//  ViewController.swift
//  SpeechSynthesizer
//
//  Created by Aurelius Prochazka on 4/7/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController {

    var speechSynthesizer = AKSpeechSynthesizer()


    @IBOutlet weak var textField: NSTextField!

    @IBOutlet weak var pitchSlider: NSSlider!
    @IBOutlet weak var rateSlider: NSSlider!
    @IBOutlet weak var modulationSlider: NSSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        let delay = AKDelay(speechSynthesizer)
        delay.time = 0.1
        delay.feedback = 0.7
        delay.dryWetMix = 0.3

        let reverb = AKReverb(delay)
        reverb.loadFactoryPreset(.cathedral)

        AudioKit.output = reverb
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }


        rateSlider.minValue = speechSynthesizer.rate / 2
        pitchSlider.minValue = speechSynthesizer.frequency / 2
        modulationSlider.minValue = 0

        rateSlider.maxValue = speechSynthesizer.rate * 2
        pitchSlider.maxValue = speechSynthesizer.frequency * 2
        modulationSlider.maxValue = speechSynthesizer.modulation * 5

        rateSlider.doubleValue = speechSynthesizer.rate
        pitchSlider.doubleValue = speechSynthesizer.frequency
        modulationSlider.doubleValue = speechSynthesizer.modulation


    }

    @IBAction func speak(_ sender: NSButton) {
        AKLog("rate: \(speechSynthesizer.rate)")
        AKLog("freq: \(speechSynthesizer.frequency)")
        AKLog("modu: \(speechSynthesizer.modulation)")
        AKLog("set rate: \(rateSlider.doubleValue)")
        AKLog("set freq: \(pitchSlider.doubleValue)")
        AKLog("set modu: \(modulationSlider.doubleValue)")
        speechSynthesizer.say(text: textField.stringValue,
                              rate: rateSlider.doubleValue,
                              frequency: pitchSlider.doubleValue,
                              modulation: modulationSlider.doubleValue)

    }

    @IBAction func stop(_ sender: NSButton) {
        speechSynthesizer.stop()
    }

}


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

    @IBOutlet weak var rateTextField: NSTextField!
    @IBOutlet weak var pitchTextField: NSTextField!
    @IBOutlet weak var modulationTextField: NSTextField!
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
        modulationSlider.maxValue = speechSynthesizer.modulation * 2

        rateSlider.integerValue = speechSynthesizer.rate
        pitchSlider.integerValue = speechSynthesizer.frequency
        modulationSlider.integerValue = speechSynthesizer.modulation
        updateLabels()
    }

    @IBAction func slid(_ sender: NSSlider) {
        speechSynthesizer.rate = rateSlider.integerValue
        speechSynthesizer.frequency = pitchSlider.integerValue
        speechSynthesizer.modulation = modulationSlider.integerValue
        updateLabels()
    }

    func updateLabels() {
        rateTextField.stringValue = "Words Per Minute: \(speechSynthesizer.rate)"
        pitchTextField.stringValue = "Base Frequency \(speechSynthesizer.frequency)"
        modulationTextField.stringValue = "Modulation: \(speechSynthesizer.modulation)"
    }

    @IBAction func speak(_ sender: NSButton) {
        speechSynthesizer.say(text: textField.stringValue)
    }

    @IBAction func stop(_ sender: NSButton) {
        speechSynthesizer.stop()
    }

}

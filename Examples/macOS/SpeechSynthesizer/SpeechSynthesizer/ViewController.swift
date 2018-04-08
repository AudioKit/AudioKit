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

        AudioKit.output = speechSynthesizer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }

    }

    @IBAction func speak(_ sender: NSButton) {
        speechSynthesizer.say(text: textField.stringValue,
                              pitch: Int(pitchSlider.intValue),
                              rate: Int(rateSlider.intValue),
                              modulation: Int(modulationSlider.intValue))

    }


}


//
//  ViewController.swift
//  AudioKitAudioUnits
//
//  Created by Aurelius Prochazka on 6/27/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Cocoa
import AVFoundation
import AudioKit

class ViewController: NSViewController {

    @IBOutlet weak var logView: NSTextField!
    var playEngine: SimplePlayEngine!

    override func viewDidLoad() {
        super.viewDidLoad()

        register()

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func toggle(_ sender: Any) {
        register()
    }
    func register() {
        AUAudioUnit.registerSubclass(AKBoosterAudioUnit.self, as: AKBooster.ComponentDescription, name: "AudioKit: Booster", version: UINT32_MAX)
        AUAudioUnit.registerSubclass(AKChowningReverbAudioUnit.self, as: AKChowningReverb.ComponentDescription, name: "AudioKit: Chowning Reverb", version: UINT32_MAX)
        AUAudioUnit.registerSubclass(AKTanhDistortionAudioUnit.self, as: AKTanhDistortion.ComponentDescription, name: "AudioKit: Tanh Distortion", version: UINT32_MAX)
        AUAudioUnit.registerSubclass(AKMorphingOscillatorBankAudioUnit.self, as: AKMorphingOscillatorBank.ComponentDescription, name: "AudioKit: Morphing Oscillator Bank", version: UINT32_MAX)
        AUAudioUnit.registerSubclass(AKPhaseDistortionOscillatorBankAudioUnit.self, as: AKPhaseDistortionOscillatorBank.ComponentDescription, name: "AudioKit: Phase Distortion Oscillator Bank", version: UINT32_MAX)
        AUAudioUnit.registerSubclass(AKOscillatorBankAudioUnit.self, as: AKOscillatorBank.ComponentDescription, name: "AudioKit: Oscillator Bank", version: UINT32_MAX)
        AVAudioUnit.instantiate(with: AKBooster.ComponentDescription, options: []) { _, _ in
            NSLog("GOT HERE")
            self.logView.stringValue += "Instantiated AKBooster\n"
        }
        AVAudioUnit.instantiate(with: AKChowningReverb.ComponentDescription, options: []) { _, _ in
            self.logView.stringValue += "Instantiated AKChowningReverb\n"

        }
        AVAudioUnit.instantiate(with: AKTanhDistortion.ComponentDescription, options: []) { _, _ in
            self.logView.stringValue += "Instantiated AKTanhDistortion\n"

        }
        AVAudioUnit.instantiate(with: AKMorphingOscillatorBank.ComponentDescription, options: []) {
            _, _ in
            self.logView.stringValue += "Instantiated AKMorphingOscillatorBank\n"

        }
        AVAudioUnit.instantiate(with: AKPhaseDistortionOscillatorBank.ComponentDescription, options: []) {
            _, _ in
            self.logView.stringValue += "Instantiated AKPhaseDistortionOscillatorBank\n"

        }
        AVAudioUnit.instantiate(with: AKOscillatorBank.ComponentDescription, options: []) { _, _ in
            self.logView.stringValue += "Instantiated AKOscillatorBank\n"

        }

    }

}

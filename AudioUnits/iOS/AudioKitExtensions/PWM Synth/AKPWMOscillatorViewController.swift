//
//  AudioUnitViewController.swift
//  PWM Synth
//
//  Created by Aurelius Prochazka on 7/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AKPWMOscillatorViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AKPWMOscillatorAudioUnit?

    public override func viewDidLoad() {
        super.viewDidLoad()

        if audioUnit == nil {
            return
        }

        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKPWMOscillatorAudioUnit(componentDescription: componentDescription, options: [])

        return audioUnit!
    }
    @IBAction func change(_ sender: UISlider) {
        guard let pwm = audioUnit,
            let pulseWidthParameter = pwm.parameterTree?.parameter(withAddress: 0)
            else { return }
        pulseWidthParameter.value = sender.value
    }

}

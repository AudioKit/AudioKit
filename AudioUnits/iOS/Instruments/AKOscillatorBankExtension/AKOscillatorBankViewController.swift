//
//  AudioUnitViewController.swift
//  AKOscillator
//
//  Created by Aurelius Prochazka on 7/9/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import CoreAudioKit
import AudioKit
import AudioKitUI

public class AKOscillatorBankViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AKOscillatorBankAudioUnit?

    @IBOutlet var slider: AKSlider!
    @IBOutlet var adsr: AKADSRView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        slider.callback = { value in
            guard let au = self.audioUnit,
                let index1 = au.parameterTree?.parameter(withAddress:5),
                let index2 = au.parameterTree?.parameter(withAddress:6)
                else { return }
            index1.value = Float(value) * 40
            index2.value = Float(value)
        }

        adsr.backgroundColor = UIColor.black
        adsr.bgColor = UIColor.black

        adsr.callback = { att, dec, sus, rel in
            guard let au = self.audioUnit,
                let attP = au.parameterTree?.parameter(withAddress:0),
                let decP = au.parameterTree?.parameter(withAddress:1),
                let susP = au.parameterTree?.parameter(withAddress:2),
                let relP = au.parameterTree?.parameter(withAddress:3)
                else { return }
            attP.value = Float(att)
            decP.value = Float(dec)
            susP.value = Float(sus)
            relP.value = Float(rel)
        }

        if audioUnit == nil {
            return
        }

        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKOscillatorBankAudioUnit(componentDescription: componentDescription, options: [])

        let waveform = AKTable(.square)
        audioUnit?.setupWaveform(Int32(waveform.count))

        for (i, sample) in waveform.enumerated() {
            audioUnit?.setWaveformValue(sample, at: UInt32(i))
        }
        return audioUnit!
    }
    @IBAction func buttonPressed(_ sender: Any) {
        let waveform = AKTable(.sine)
        for (i, sample) in waveform.enumerated() {
            audioUnit?.setWaveformValue(sample, at: UInt32(i))
        }
    }
}

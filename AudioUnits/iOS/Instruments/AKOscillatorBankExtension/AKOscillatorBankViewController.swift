//
//  AudioUnitViewController.swift
//  AKOscillator
//
//  Created by Aurelius Prochazka on 7/9/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AKOscillatorBankAudioUnit?

    public override func viewDidLoad() {
        super.viewDidLoad()

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

    @IBAction func sliderSlid(_ sender: UISlider) {
        guard let au = audioUnit,
            let index1 = au.parameterTree?.parameter(withAddress:5),
            let index2 = au.parameterTree?.parameter(withAddress:6)
            else { return }
        index1.value = sender.value * 40
        index2.value = sender.value
    }

}

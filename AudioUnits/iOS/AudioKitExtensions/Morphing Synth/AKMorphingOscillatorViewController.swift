//
//  AudioUnitViewController.swift
//  Morphing Synth
//
//  Created by Aurelius Prochazka on 7/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AKMorphingOscillatorViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AKMorphingOscillatorBankAudioUnit?

    public override func viewDidLoad() {
        super.viewDidLoad()

        if audioUnit == nil {
            return
        }

        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKMorphingOscillatorBankAudioUnit(componentDescription: componentDescription, options: [])

        let waveformArray = [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)]
        for (i, waveform) in waveformArray.enumerated() {
            audioUnit?.setupWaveform(UInt32(i), size: Int32(UInt32(waveform.count)))
            for (j, sample) in waveform.enumerated() {
                audioUnit?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
            }
        }

        return audioUnit!
    }

    @IBAction func change(_ sender: UISlider) {
        guard let au = audioUnit,
            let index = au.parameterTree?.parameter(withAddress: 0)
            else { return }
        index.value = sender.value
    }

}

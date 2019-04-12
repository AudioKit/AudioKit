//
//  AKOscillatorBankViewController.swift
//  AKOscillatorBankExtension
//
//  Created by Aurelius Prochazka on 6/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit

public class AKOscillatorBankViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AKOscillatorBankAudioUnit?

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSSize(width: 800, height: 500)
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        if audioUnit == nil {
            return
        }

        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKOscillatorBankAudioUnit(componentDescription: componentDescription, options: [])

        // Do any default set up stuff
        let waveform = AKTable(.sine)
        audioUnit?.setupWaveform(Int32(waveform.count))
        for (i, sample) in waveform.enumerated() {
            audioUnit?.setWaveformValue(sample, at: UInt32(i))
        }

        return audioUnit!
    }

    @IBAction func updateDetuningMultiplier(_ sender: NSSlider) {
        guard let audioUnit = audioUnit,
            let detuningMultiplier = audioUnit.parameterTree?.parameter(withAddress: 5)
            else { return }
        detuningMultiplier.value = sender.floatValue
    }

}

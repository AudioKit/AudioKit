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

    @IBOutlet var vibratoDepthSlider: AKSlider!
    @IBOutlet var vibratoRateSlider: AKSlider!
    @IBOutlet var waveformButton: AKButton!
    @IBOutlet var adsr: AKADSRView!

    var waveformIndex = 0
    let waveformNames = ["Sine",
                         "Square",
                         "Triangle",
                         "Sawtooth",
                         "Reverse Sawtooth"]
    let waveforms = [AKTable(.sine),
                     AKTable(.square),
                     AKTable(.triangle),
                     AKTable(.sawtooth),
                     AKTable(.reverseSawtooth)]

    public override func viewDidLoad() {
        super.viewDidLoad()

        AKStylist.sharedInstance.theme = .midnight

        vibratoDepthSlider.textColor = UIColor.black
        vibratoDepthSlider.property = "Depth"
        vibratoDepthSlider.range = 0 ... 12
        vibratoDepthSlider.value = 0
        vibratoDepthSlider.callback = { value in
            guard let au = self.audioUnit,
                let vibratoDepth = au.parameterTree?.parameter(withAddress: 5)
                else { return }
            vibratoDepth.value = Float(value)
        }

        vibratoRateSlider.textColor = UIColor.white
        vibratoRateSlider.property = "Rate"
        vibratoRateSlider.range = 0 ... 10
        vibratoRateSlider.value = 0
        vibratoRateSlider.callback = { value in
            guard let au = self.audioUnit,
                let vibratoRate = au.parameterTree?.parameter(withAddress: 6)
                else { return }
            vibratoRate.value = Float(value)
        }

        waveformButton.title = waveformNames[waveformIndex]
        waveformButton.callback = { button in
            self.nextWaveform()
            button.title = self.waveformNames[self.waveformIndex]
        }

        adsr.backgroundColor = UIColor.black
        adsr.bgColor = UIColor.black

        adsr.callback = { att, dec, sus, rel in
            guard let au = self.audioUnit,
                let attP = au.parameterTree?.parameter(withAddress: 0),
                let decP = au.parameterTree?.parameter(withAddress: 1),
                let susP = au.parameterTree?.parameter(withAddress: 2),
                let relP = au.parameterTree?.parameter(withAddress: 3)
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

        let waveform = waveforms[waveformIndex]
        audioUnit?.setupWaveform(Int32(waveform.count))

        for (i, sample) in waveform.enumerated() {
            audioUnit?.setWaveformValue(sample, at: UInt32(i))
        }
        return audioUnit!
    }
    func nextWaveform() {
        waveformIndex += 1
        waveformIndex %= waveforms.count
        let waveform = waveforms[waveformIndex]
        for (i, sample) in waveform.enumerated() {
            audioUnit?.setWaveformValue(sample, at: UInt32(i))
        }
    }
}

//
//  AudioUnitViewController.swift
//  AKOscillatorExtension
//
//  Created by Aurelius Prochazka on 7/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit
import AudioKitUI

open class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AKOscillatorBankAudioUnit? {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.connectViewWithAU()
                }
            }
        }
    }

    @IBOutlet weak var adsr: AKADSRView!
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black

        guard audioUnit != nil else { return }

        connectViewWithAU()

    }

    open func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKOscillatorBankAudioUnit(componentDescription: componentDescription, options: [])

        // Do any default set up stuff
        let waveform = AKTable(.sine)
        audioUnit?.setupWaveform(Int32(waveform.count))
        for (i, sample) in waveform.enumerated() {
            audioUnit?.setWaveformValue(sample, at: UInt32(i))
        }

        return audioUnit!
    }

    func connectViewWithAU() {
        adsr.backgroundColor = UIColor.black
        adsr.bgColor = UIColor.black
        adsr.callback = {  att, dec, sus, rel in
            self.audioUnit?.parameterTree?.parameter(withAddress: 0)!.value = Float(att)
            self.audioUnit?.parameterTree?.parameter(withAddress: 1)!.value = Float(dec)
            self.audioUnit?.parameterTree?.parameter(withAddress: 2)!.value = Float(sus)
            self.audioUnit?.parameterTree?.parameter(withAddress: 3)!.value = Float(rel)
        }
    }
}

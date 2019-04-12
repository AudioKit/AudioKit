//
//  AKPhaseDistortionOscillatorViewController.swift
//  AKPhaseDistortionOscillatorBan
//
//  Created by Aurelius Prochazka on 6/30/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import CoreAudioKit
import AudioKit
import AudioKitUI

public class AKPhaseDistortionOscillatorViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AKPhaseDistortionOscillatorBankAudioUnit? {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.connectViewWithAU()
                }
            }
        }
    }

    var indexSlider: AKSlider!
    var adsr: AKADSRView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = NSSize(width: 900, height: 564)

        guard audioUnit != nil else { return }
        view.superview?.window!.styleMask.remove(NSWindow.StyleMask.resizable)
        connectViewWithAU()
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try AKPhaseDistortionOscillatorBankAudioUnit(componentDescription: componentDescription, options: [])

        // Do any default set up stuff
        let waveform = AKTable(.sine)
        audioUnit?.setupWaveform(Int32(waveform.count))
        for (i, sample) in waveform.enumerated() {
            audioUnit?.setWaveformValue(sample, at: UInt32(i))
        }

        return audioUnit!
    }

    override public func preferredContentSizeDidChange(for viewController: NSViewController) {
        connectViewWithAU()
    }

    func connectViewWithAU() {

        indexSlider = AKSlider(
            property: "Phase Distortion",
            value: 0.5,
            color: .red,
            frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height - 50),
                          size: CGSize(width: view.frame.width, height: 50))) { sliderValue in
            self.audioUnit?.parameterTree?.parameter(withAddress: 0)!.value = Float(sliderValue)
        }
        view.addSubview(indexSlider)

        adsr = AKADSRView { att, dec, sus, rel in
            self.audioUnit?.parameterTree?.parameter(withAddress: 1)!.value = Float(att)
            self.audioUnit?.parameterTree?.parameter(withAddress: 2)!.value = Float(dec)
            self.audioUnit?.parameterTree?.parameter(withAddress: 3)!.value = Float(sus)
            self.audioUnit?.parameterTree?.parameter(withAddress: 4)!.value = Float(rel)
        }
        adsr.setFrameSize(NSSize(width: view.frame.width, height: view.frame.height - 50))
        adsr.setFrameOrigin(NSPoint(x: 0, y: 0))
        view.addSubview(adsr)

    }
}

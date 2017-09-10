//
//  PitchShifterViewController.swift
//  SongProcessor
//
//  Created by Elizabeth Simonian on 10/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class PitchShifterViewController: UIViewController {

    @IBOutlet private weak var pitchSlider: AKSlider!
    @IBOutlet private weak var mixSlider: AKSlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        pitchSlider.range = -24 ... 24

        pitchSlider.value = songProcessor.pitchShifter.shift

        mixSlider.value = songProcessor.pitchMixer.balance
        mixSlider.callback = updateMix
        pitchSlider.callback = updatePitch

    }

    func updatePitch(value: Double) {
        songProcessor.pitchShifter.shift = value
    }

    func updateMix(value: Double) {
        songProcessor.pitchMixer.balance = value
    }

}

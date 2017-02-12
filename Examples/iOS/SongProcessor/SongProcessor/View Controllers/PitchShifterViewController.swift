//
//  PitchShifterViewController.swift
//  SongProcessor
//
//  Created by Elizabeth Simonian on 10/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class PitchShifterViewController: UIViewController {

    @IBOutlet private weak var pitchSlider: AKPropertySlider!
    @IBOutlet private weak var mixSlider: AKPropertySlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        pitchSlider.minimum = -24
        pitchSlider.maximum = 24

        if let pitch = songProcessor.pitchShifter?.shift {
            pitchSlider.value = pitch
        }
        if let balance = songProcessor.pitchMixer?.balance {
            mixSlider.value = balance
        }

        mixSlider.callback = updateMix
        pitchSlider.callback = updatePitch

    }

    func updatePitch(value: Double) {
        songProcessor.pitchShifter?.shift = value
    }

    func updateMix(value: Double) {
        songProcessor.pitchMixer?.balance = value
    }

}

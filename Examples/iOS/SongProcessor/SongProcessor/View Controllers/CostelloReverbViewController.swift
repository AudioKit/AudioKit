//
//  CostelloReverbViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class CostelloReverbViewController: UIViewController {

    @IBOutlet private weak var feedbackSlider: AKSlider!
    @IBOutlet private weak var mixSlider: AKSlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        feedbackSlider.value = songProcessor.reverb.feedback
        mixSlider.value = songProcessor.reverbMixer.balance

        mixSlider.callback = updateMix
        feedbackSlider.callback = updateFeedback
    }

    func updateFeedback(value: Double) {
        songProcessor.reverb.feedback = value
    }

    func updateMix(value: Double) {
        songProcessor.reverbMixer.balance = value
    }

}

//
//  VariableDelayViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class VariableDelayViewController: UIViewController {

    @IBOutlet private weak var timeSlider: AKSlider!
    @IBOutlet private weak var feedbackSlider: AKSlider!
    @IBOutlet private weak var mixSlider: AKSlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        timeSlider.value = songProcessor.variableDelay.time

        feedbackSlider.value = songProcessor.variableDelay.feedback

        mixSlider.value = songProcessor.delayMixer.balance

        timeSlider.callback = updateTime
        feedbackSlider.callback = updateFeedback
        mixSlider.callback = updateMix
    }

    func updateTime(value: Double) {
        songProcessor.variableDelay.time = value
    }

    func updateFeedback(value: Double) {
        songProcessor.variableDelay.feedback = value
    }

    func updateMix(value: Double) {
        songProcessor.delayMixer.balance = value
    }

}

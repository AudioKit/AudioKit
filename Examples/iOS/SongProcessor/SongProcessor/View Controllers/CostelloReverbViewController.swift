//
//  CostelloReverbViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class CostelloReverbViewController: UIViewController {

    @IBOutlet private weak var feedbackSlider: AKPropertySlider!
    @IBOutlet private weak var mixSlider: AKPropertySlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        if let feedback = songProcessor.reverb?.feedback {
            feedbackSlider.value = feedback
        }
        if let balance = songProcessor.reverbMixer?.balance {
            mixSlider.value = balance
        }

        mixSlider.callback = updateMix
        feedbackSlider.callback = updateFeedback
    }

    func updateFeedback(value: Double) {
        songProcessor.reverb?.feedback = value
    }

    func updateMix(value: Double) {
        songProcessor.reverbMixer?.balance = value
    }

}

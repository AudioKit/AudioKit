//
//  MoogLadderViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class MoogLadderViewController: UIViewController {

    @IBOutlet private weak var cutoffFrequncySlider: AKSlider!
    @IBOutlet private weak var resonanceSlider: AKSlider!
    @IBOutlet private weak var mixSlider: AKSlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        cutoffFrequncySlider.range = 12.0 ... 10_000.0
        cutoffFrequncySlider.taper = 3

        cutoffFrequncySlider.value = songProcessor.moogLadder.cutoffFrequency

        resonanceSlider.value = songProcessor.moogLadder.resonance

        mixSlider.value = songProcessor.filterMixer.balance

        cutoffFrequncySlider.callback = updateCutoffFrequncy
        resonanceSlider.callback = updateResonance
        mixSlider.callback = updateMix
    }

    func updateCutoffFrequncy(value: Double) {
        songProcessor.moogLadder.cutoffFrequency = value
    }

    func updateResonance(value: Double) {
        songProcessor.moogLadder.resonance = value
    }

    func updateMix(value: Double) {
        songProcessor.filterMixer.balance = value
    }
}

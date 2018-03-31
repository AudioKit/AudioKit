//
//  BitCrusherViewController.swift
//  SongProcessor
//
//  Created by Elizabeth Simonian, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class BitCrusherViewController: UIViewController {

    @IBOutlet private weak var bitDepthSlider: AKSlider!
    @IBOutlet private weak var sampleRateSlider: AKSlider!
    @IBOutlet private weak var mixSlider: AKSlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        bitDepthSlider.range = 1 ... 24
        sampleRateSlider.range = 0 ... 16_000

        bitDepthSlider.value = songProcessor.bitCrusher.bitDepth
        sampleRateSlider.value = songProcessor.bitCrusher.sampleRate
        mixSlider.value = songProcessor.bitCrushMixer.balance

        bitDepthSlider.callback = updateBitDepth
        sampleRateSlider.callback = updateSampleRate
        mixSlider.callback = updateMix

    }

    func updateBitDepth(value: Double) {
        songProcessor.bitCrusher.bitDepth = value
    }

    func updateSampleRate(value: Double) {
        songProcessor.bitCrusher.sampleRate = value
    }

    func updateMix(value: Double) {
        songProcessor.bitCrushMixer.balance = value
    }

}

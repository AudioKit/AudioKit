//
//  BitCrusherViewController.swift
//  SongProcessor
//
//  Created by Elizabeth Simonian on 10/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class BitCrusherViewController: UIViewController {

    @IBOutlet private weak var bitDepthSlider: AKPropertySlider!
    @IBOutlet private weak var sampleRateSlider: AKPropertySlider!
    @IBOutlet private weak var mixSlider: AKPropertySlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        bitDepthSlider.minimum = 1
        bitDepthSlider.maximum = 24
        sampleRateSlider.maximum = 16_000

        if let bitDepth = songProcessor.bitCrusher?.bitDepth {
            bitDepthSlider.value = bitDepth
        }

        if let sampleRate = songProcessor.bitCrusher?.sampleRate {
            sampleRateSlider.value = sampleRate
        }

        if let balance = songProcessor.bitCrushMixer?.balance {
            mixSlider.value = balance
        }

        bitDepthSlider.callback = updateBitDepth
        sampleRateSlider.callback = updateSampleRate
        mixSlider.callback = updateMix

    }

    func updateBitDepth(value: Double) {
        songProcessor.bitCrusher?.bitDepth = value
    }

    func updateSampleRate(value: Double) {
        songProcessor.bitCrusher?.sampleRate = value
    }

    func updateMix(value: Double) {
        songProcessor.bitCrushMixer?.balance = value
    }

}

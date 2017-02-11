//
//  EffectsViewController.swift
//  SongProcessor
//
//  Created by Elizabeth Simonian on 10/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class EffectsViewController: UIViewController {

    @IBOutlet weak var volumeSlider: AKPropertySlider!

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        volumeSlider.maximum = 10.0

        if let volume = songProcessor.playerBooster?.gain {
            volumeSlider.value = volume
        }
        volumeSlider.callback = updateVolume
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateVolume(value: Double) {
        songProcessor.playerBooster?.gain = value
    }

}

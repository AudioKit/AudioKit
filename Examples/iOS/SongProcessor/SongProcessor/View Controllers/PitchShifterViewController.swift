//
//  PitchShifterViewController.swift
//  SongProcessor
//
//  Created by Elizabeth Simonian on 10/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class PitchShifterViewController: UIViewController {
    
    @IBOutlet weak var pitchSlider: AKPropertySlider!
    @IBOutlet weak var mixSlider: AKPropertySlider!
    
    let songProcessor = SongProcessor.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

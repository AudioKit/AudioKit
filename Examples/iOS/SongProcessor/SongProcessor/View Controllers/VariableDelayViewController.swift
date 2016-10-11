//
//  VariableDelayViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class VariableDelayViewController: UIViewController {
    
    @IBOutlet weak var timeSlider: AKPropertySlider!
    @IBOutlet weak var feedbackSlider: AKPropertySlider!
    @IBOutlet weak var mixSlider: AKPropertySlider!
    
    let songProcessor = SongProcessor.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let time = songProcessor.variableDelay?.time {
            timeSlider.value = time
        }
        
        if let feedback = songProcessor.variableDelay?.feedback {
            feedbackSlider.value = feedback
        }
        
        if let balance = songProcessor.delayMixer?.balance {
            mixSlider.value = balance
        }
        
        timeSlider.callback = updateTime
        feedbackSlider.callback = updateFeedback
        mixSlider.callback = updateMix
    }
    
    func updateTime(value: Double) {
        songProcessor.variableDelay?.time = value
    }
    
    func updateFeedback(value: Double) {
        songProcessor.variableDelay?.feedback = value
    }
    
    func updateMix(value: Double) {
       songProcessor.delayMixer?.balance = value
    }
    
}

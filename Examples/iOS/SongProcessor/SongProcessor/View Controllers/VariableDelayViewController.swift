//
//  VariableDelayViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

class VariableDelayViewController: UIViewController {
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var feedbackSlider: UISlider!
    @IBOutlet weak var mixSlider: UISlider!
    
    let songProcessor = SongProcessor.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let time = songProcessor.variableDelay?.time {
            timeSlider.value = Float(time)
        }
        if let feedback = songProcessor.variableDelay?.feedback {
            feedbackSlider.value = Float(feedback)
        }
        if let balance = songProcessor.delayMixer?.balance {
            mixSlider.value = Float(balance)
        }
    }
    
    @IBAction func updateTime(_ sender: UISlider) {
        songProcessor.variableDelay?.time = Double(sender.value)
    }

    @IBAction func updateFeedback(_ sender: UISlider) {
        songProcessor.variableDelay?.feedback = Double(sender.value)
    }

    @IBAction func updateMix(_ sender: UISlider) {
        songProcessor.delayMixer?.balance = Double(sender.value)
    }
    
}

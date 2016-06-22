//
//  CostelloReverbViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

class CostelloReverbViewController: UIViewController {
    
    @IBOutlet weak var feedbackSlider: UISlider!
    @IBOutlet weak var mixSlider: UISlider!
    
    let songProcessor = SongProcessor.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let feedback = songProcessor.reverb?.feedback {
            feedbackSlider.value = Float(feedback)
        }
        if let balance = songProcessor.reverbMixer?.balance {
            mixSlider.value = Float(balance)
        }
    }
    
    
    @IBAction func updateFeedback(sender: UISlider) {
        songProcessor.reverb?.feedback = Double(sender.value)
    }
    
    @IBAction func updateMix(sender: UISlider) {
        songProcessor.reverbMixer?.balance = Double(sender.value)
    }
}

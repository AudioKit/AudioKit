//
//  MoogLadderViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

class MoogLadderViewController: UIViewController {
    
    @IBOutlet weak var cutoffFrequncySlider: UISlider!
    @IBOutlet weak var resonanceSlider: UISlider!
    @IBOutlet weak var mixSlider: UISlider!
    
    let songProcessor = SongProcessor.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        cutoffFrequncySlider.minimumValue = 12.0
        cutoffFrequncySlider.maximumValue = 10000.0
        
        if let freq = songProcessor.moogLadder?.cutoffFrequency {
            cutoffFrequncySlider.value = Float(freq)
        }
        
        if let res = songProcessor.moogLadder?.resonance {
            resonanceSlider.value = Float(res)
        }
        
        if let balance = songProcessor.filterMixer?.balance {
            mixSlider.value = Float(balance)
        }
    }
    
    @IBAction func updateCutoff(sender: UISlider) {
        songProcessor.moogLadder?.cutoffFrequency = Double(sender.value)
    }
    
    @IBAction func updateResonance(sender: UISlider) {
        songProcessor.moogLadder?.resonance = Double(sender.value)
    }
    @IBAction func updateMix(sender: UISlider) {
        songProcessor.filterMixer?.balance = Double(sender.value)
    }
}
